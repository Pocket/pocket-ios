// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Foundation

@testable import Sync

class OSNotificationCenterTests: XCTestCase {
    var cfCenter: CFNotificationCenter!

    override func setUp() {
        super.setUp()
        cfCenter = CFNotificationCenterGetDarwinNotifyCenter()
    }

    func test_register_registersGivenObserverWithGivenHandler() {
        let center = OSNotificationCenter(notifications: cfCenter)

        let notificationWasHandled = expectation(description: "notificationWasHandled")
        center.add(observer: self, name: .testNotification) {
            notificationWasHandled.fulfill()
        }

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)
        wait(for: [notificationWasHandled], timeout: 10)
    }

    func test_register_whenAlreadyRegistered_addsBothObservers() {
        let center = OSNotificationCenter(notifications: cfCenter)

        let notificationWasHandled = expectation(description: "notificationWasHandled")
        center.add(observer: self, name: .testNotification) {
            notificationWasHandled.fulfill()
        }

        let notificationWasHandled2 = expectation(description: "notificationWasHandled2")
        center.add(observer: self, name: .testNotification) {
            notificationWasHandled2.fulfill()
        }

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)
        wait(for: [notificationWasHandled, notificationWasHandled2], timeout: 10)
    }

    func test_remove_removesGivenObserverForGivenNotification() {
        let center = OSNotificationCenter(notifications: cfCenter)

        let observers = [UUID(), UUID()]
        center.add(observer: observers[0], name: .testNotification) {
            XCTFail("Observer 1 should not be notified after being removed")
        }

        let observer2HandledNotification = expectation(description: "observer2HandledNotification")
        center.add(observer: observers[1], name: .testNotification) {
            observer2HandledNotification.fulfill()
        }

        center.remove(observer: observers[0], name: .testNotification)

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)
        wait(for: [observer2HandledNotification], timeout: 10)
    }

    func test_remove_whenObservingWithMultipleHandlers_removesAllHandlers() {
        let center = OSNotificationCenter(notifications: cfCenter)

        center.add(observer: self, name: .testNotification) {
            XCTFail("Should not be notified after removing")
        }
        center.add(observer: self, name: .testNotification) {
            XCTFail("Should not be notified after removing")
        }
        center.remove(observer: self, name: .testNotification)

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)

        // In order to trigger a proper failure, we need to give the OS some time
        // to invoke notification handlers.
        let pause = expectation(description: "pause")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            pause.fulfill()
        }
        wait(for: [pause], timeout: 10)
    }

    func test_remove_doesNotRemoveHandlerForOtherNotifications() {
        let center = OSNotificationCenter(notifications: cfCenter)

        center.add(observer: self, name: .testNotification) {
            XCTFail("Observer 1 should not be notified of `testNotification` after being removed")
        }

        let wasNotifiedOfAnotherTestNotification = expectation(description: "wasNotifiedOfAnotherTestNotification")
        center.add(observer: self, name: .anotherTestNotification) {
            wasNotifiedOfAnotherTestNotification.fulfill()
        }

        center.remove(observer: self, name: .testNotification)

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)
        CFNotificationCenterPostNotification(cfCenter, .anotherTestNotification, nil, nil, true)

        wait(for: [wasNotifiedOfAnotherTestNotification], timeout: 10)
    }

    func test_remove_doesNotRetainObservers() {
        class Observer: NSObject {}

        let center = OSNotificationCenter(notifications: cfCenter)
        weak var weakObserver: Observer?
        autoreleasepool {
            var observer: Observer? = Observer()
            weakObserver = observer

            center.add(observer: observer, name: .testNotification) {
                XCTFail("Observer 1 should not be notified of `testNotification` after being removed")
            }

            center.remove(observer: observer, name: .testNotification)

            observer = nil
        }

        XCTAssertNil(weakObserver)
    }

    func test_add_retainsObservers() {
        class Observer: NSObject {}

        let center = OSNotificationCenter(notifications: cfCenter)
        let receivedNotification = expectation(description: "receivedNotification")

        autoreleasepool {
            let observer: Observer = Observer()
            center.add(observer: observer, name: .testNotification) {
                receivedNotification.fulfill()
            }
        }

        CFNotificationCenterPostNotification(cfCenter, .testNotification, nil, nil, true)
        wait(for: [receivedNotification], timeout: 10)
    }
}

extension CFNotificationName {
    static let testNotification: CFNotificationName = .init(rawValue: "testNotification" as CFString)
    static let anotherTestNotification: CFNotificationName = .init(rawValue: "anotherTestNotification" as CFString)
}
