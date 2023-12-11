// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BackgroundTasks
@testable import PocketKit

class MockBGTaskScheduler: BGTaskSchedulerProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - registerHandler
extension MockBGTaskScheduler {
    static let registerHandler = "registerHandler"

    typealias RegisterHandlerImpl = (String, DispatchQueue?, @escaping (BGTaskProtocol) -> Void) -> Bool

    struct RegisterHandlerCall {
        let identifier: String
        let queue: DispatchQueue?
        let launchHandler: (BGTaskProtocol) -> Void
    }

    func stubRegisterHandler(impl: @escaping RegisterHandlerImpl) {
        implementations[Self.registerHandler] = impl
    }

    func registerHandler(
        forTaskWithIdentifier identifier: String,
        using queue: DispatchQueue?,
        launchHandler: @escaping (BGTaskProtocol) -> Void
    ) -> Bool {
        guard let impl = implementations[Self.registerHandler] as? RegisterHandlerImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.registerHandler] = (calls[Self.registerHandler] ?? []) + [
            RegisterHandlerCall(identifier: identifier, queue: queue, launchHandler: launchHandler)
        ]

        return impl(identifier, queue, launchHandler)
    }

    func registerHandlerCall(at index: Int) -> RegisterHandlerCall? {
        guard let calls = calls[Self.registerHandler], calls.count > index,
              let call = calls[index] as? RegisterHandlerCall else {
                  return nil
              }

        return call
    }
}

// MARK: - submit
extension MockBGTaskScheduler {
    static let submit = "submit"

    typealias SubmitImpl = (BGTaskRequest) throws -> Void

    struct SubmitCall {
        let taskRequest: BGTaskRequest
    }

    func stubSubmit(impl: @escaping SubmitImpl) {
        implementations[Self.submit] = impl
    }

    func submit(_ taskRequest: BGTaskRequest) throws {
        guard let impl = implementations[Self.submit] as? SubmitImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.submit] = (calls[Self.submit] ?? []) + [
            SubmitCall(taskRequest: taskRequest)
        ]

        try impl(taskRequest)
    }

    func submitCall(at index: Int) -> SubmitCall? {
        guard let calls = calls[Self.submit], calls.count > index,
              let call = calls[index] as? SubmitCall else {
                    return nil
        }

        return call
    }
}

// MARK: - cancel
extension MockBGTaskScheduler {
    static let cancel = "cancel"

    typealias CancelImpl = (String) -> Void

    struct CancelCall {
        let identifier: String
    }

    func stubCancel(impl: @escaping CancelImpl) {
        implementations[Self.cancel] = impl
    }

    func cancel(_ identifier: String) {
        guard let impl = implementations[Self.cancel] as? CancelImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.cancel] = (calls[Self.cancel] ?? []) + [
            CancelCall(identifier: identifier)
        ]

        impl(identifier)
    }

    func cancelCall(at index: Int) -> CancelCall? {
        guard let calls = calls[Self.cancel], calls.count > index,
              let call = calls[index] as? CancelCall else {
                    return nil
        }

        return call
    }
}

class MockBGTask: BGTaskProtocol {
    var expirationHandler: (() -> Void)?

    var implementations: [String: Any] = [:]
    var calls: [String: [Any]] = [:]
}

// MARK: - setTaskCompleted
extension MockBGTask {
    static let setTaskCompleted = "setTaskCompleted"
    typealias SetTaskCompletedImpl = (Bool) -> Void

    struct SetTaskCompletedCall {
        let success: Bool
    }

    func stubSetTaskCompleted(impl: @escaping SetTaskCompletedImpl) {
        implementations[Self.setTaskCompleted] = impl
    }

    func setTaskCompleted(success: Bool) {
        guard let impl = implementations[Self.setTaskCompleted] as? SetTaskCompletedImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.setTaskCompleted] = (calls[Self.setTaskCompleted] ?? []) + [
            SetTaskCompletedCall(success: success)
        ]

        impl(success)
    }

    func setTaskCompletedCall(at index: Int) -> SetTaskCompletedCall? {
        guard let calls = calls[Self.setTaskCompleted], calls.count > index,
              let call = calls[index] as? SetTaskCompletedCall else {
                    return nil
        }

        return call
    }
}
