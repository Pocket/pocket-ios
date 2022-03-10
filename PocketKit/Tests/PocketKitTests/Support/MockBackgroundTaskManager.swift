@testable import PocketKit
import UIKit


class MockBackgroundTaskManager: BackgroundTaskManager {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}


// MARK: - beginTask
extension MockBackgroundTaskManager {
    private static let beginTask = "beginTask"

    typealias BeginTaskImpl = (String?, (() -> Void)?) -> UIBackgroundTaskIdentifier

    struct BeginTaskCall {
        let name: String?
        let expirationHandler: (() -> Void)?
    }

    func stubBeginTask(impl: @escaping BeginTaskImpl) {
        implementations[Self.beginTask] = impl
    }

    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        guard let impl = implementations[Self.beginTask] as? BeginTaskImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.beginTask] = (calls[Self.beginTask] ?? []) + [
            BeginTaskCall(name: name, expirationHandler: expirationHandler)
        ]

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

    typealias EndTaskImpl = (UIBackgroundTaskIdentifier) -> Void

    struct EndTaskCall {
        let identifier: UIBackgroundTaskIdentifier
    }

    func stubEndTask(impl: @escaping EndTaskImpl) {
        implementations[Self.endTask] = impl
    }

    func endTask(_ identifier: UIBackgroundTaskIdentifier) {
        guard let impl = implementations[Self.endTask] as? EndTaskImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.endTask] = (calls[Self.endTask] ?? []) + [
            EndTaskCall(identifier: identifier)
        ]

        impl(identifier)
    }

    func endTaskCall(at index: Int) -> EndTaskCall? {
        guard let calls = calls[Self.endTask], calls.count > index else {
            return nil
        }

        return calls[index] as? EndTaskCall
    }
}
