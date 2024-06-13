// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreFoundation

public final class OSNotificationCenter: Sendable {
    public typealias Observer = AnyHashable
    nonisolated(unsafe) private let center: CFNotificationCenter
    private let storage: Storage

    public init(notifications: CFNotificationCenter) {
        self.center = notifications
        self.storage = Storage()
    }

    deinit {
        removeAllObservers()
    }

    public func add(observer: Observer, name: CFNotificationName, handler: @escaping () -> Void) {
        let notificationHandler = NotificationHandler(handler: handler)
        storage.add(observer: observer, name: name, handler: notificationHandler)

        CFNotificationCenterAddObserver(
            center,
            notificationHandler.pointer,
            notificationHandler.callback,
            name.rawValue,
            nil,
            .deliverImmediately
        )
    }

    public func remove(observer: Observer, name: CFNotificationName) {
        storage
            .handlers(for: observer, name: name)?
            .forEach { handler in
                CFNotificationCenterRemoveObserver(center, handler.pointer, name, nil)
            }

        storage.remove(observer: observer, name: name)
    }

    public func post(name: CFNotificationName) {
        CFNotificationCenterPostNotification(center, name, nil, nil, true)
    }

    public func removeAllObservers() {
        storage.forEach { observer, notificationName, handler in
            CFNotificationCenterRemoveObserver(center, handler.pointer, notificationName, nil)
        }

        storage.clear()
    }

    private final class Storage: Sendable {
        private struct Key: Hashable {
            let observer: Observer
            let notificationName: CFNotificationName

            init(_ observer: Observer, _ notificationName: CFNotificationName) {
                self.observer = observer
                self.notificationName = notificationName
            }
        }

        nonisolated(unsafe) private var _handlers: [Key: [NotificationHandler]] = [:]

        func add(observer: Observer, name: CFNotificationName, handler: NotificationHandler) {
            let key = Key(observer, name)
            _handlers[key] = (_handlers[key] ?? []) + [handler]
        }

        func remove(observer: Observer, name: CFNotificationName) {
            _handlers[Key(observer, name)] = nil
        }

        func handlers(for observer: Observer, name: CFNotificationName) -> [NotificationHandler]? {
            _handlers[Key(observer, name)]
        }

        func forEach(closure: (Observer, CFNotificationName, NotificationHandler) -> Void) {
            _handlers.forEach { key, handlers in
                handlers.forEach { handler in
                    closure(key.observer, key.notificationName, handler)
                }
            }
        }

        func clear() {
            _handlers = [:]
        }
    }

    private class NotificationHandler {
        private let handler: () -> Void

        init(handler: @escaping () -> Void) {
            self.handler = handler
        }

        var pointer: UnsafeMutableRawPointer {
            Unmanaged<NotificationHandler>.passUnretained(self).toOpaque()
        }

        var callback: CFNotificationCallback {
            { _, pointer, _, _, _ in
                pointer.flatMap {
                    Unmanaged<NotificationHandler>.fromOpaque($0).takeUnretainedValue()
                }?.handler()
            }
        }
    }
}
