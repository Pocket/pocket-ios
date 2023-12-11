// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync

class MockExpiringActivityPerformer: ExpiringActivityPerformer {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockExpiringActivityPerformer {
    static let performImpl = "performImpl"
    typealias PerformImpl = (String, @escaping (Bool) -> Void) -> Void

    struct PerformCall {
        let reason: String
    }

    func stubPerformExpiringActivity(_ impl: @escaping PerformImpl) {
        implementations[Self.performImpl] = impl
    }

    func performCall(at index: Int) -> PerformCall? {
        calls[Self.performImpl]?[index] as? PerformCall
    }

    func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void) {
        guard let impl = implementations[Self.performImpl] as? PerformImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.performImpl] = (calls[Self.performImpl] ?? []) + [PerformCall(reason: reason)]
        impl(reason, block)
    }
}
