// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync
import Foundation

class MockBackgroundTaskManager: BackgroundTaskManager {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
    private var lock: DispatchQueue = DispatchQueue(label: "")
}

// MARK: - beginTask
extension MockBackgroundTaskManager {
    private static let beginTask = "beginTask"

    typealias BeginTaskImpl = (String?, (() -> Void)?) -> Int

    struct BeginTaskCall {
        let name: String?
        let expirationHandler: (() -> Void)?
    }

    func stubBeginTask(impl: @escaping BeginTaskImpl) {
        implementations[Self.beginTask] = impl
    }

    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int {
        guard let impl = implementations[Self.beginTask] as? BeginTaskImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        lock.sync {
            calls[Self.beginTask] = (calls[Self.beginTask] ?? []) + [
                BeginTaskCall(name: name, expirationHandler: expirationHandler)
            ]
        }

        return impl(name, expirationHandler)
    }

    func beginTaskCall(at index: Int) -> BeginTaskCall? {
        guard let calls = calls[Self.beginTask], calls.count > index else {
            return nil
        }

        return calls[index] as? BeginTaskCall
    }
}

// MARK: - endTask
extension MockBackgroundTaskManager {
    private static let endTask = "endTask"

    typealias EndTaskImpl = (Int) -> Void

    struct EndTaskCall {
        let identifier: Int
    }

    func stubEndTask(impl: @escaping EndTaskImpl) {
        implementations[Self.endTask] = impl
    }

    func endTask(_ identifier: Int) {
        guard let impl = implementations[Self.endTask] as? EndTaskImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }
        lock.sync {
            calls[Self.endTask] = (calls[Self.endTask] ?? []) + [
                EndTaskCall(identifier: identifier)
            ]
        }

        impl(identifier)
    }

    func endTaskCall(at index: Int) -> EndTaskCall? {
        guard let calls = calls[Self.endTask], calls.count > index else {
            return nil
        }

        return calls[index] as? EndTaskCall
    }
}
