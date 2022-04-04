// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo

public class MockCancellable: Cancellable {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockCancellable {
    private static let cancel = "cancel"
    public typealias CancelImpl = () -> Void
    public struct CancelCall { }

    public func stubCancel(impl: @escaping CancelImpl) {
        implementations[Self.cancel] = impl
    }

    public func cancelCall(at index: Int) -> CancelCall? {
        guard let calls = calls[Self.cancel],
                calls.count > index else {
            return nil
        }

        return calls[index] as? CancelCall
    }

    public func cancel() {
        calls[Self.cancel] = (calls[Self.cancel] ?? []) + [CancelCall()]

        guard let impl = implementations[Self.cancel] as? CancelImpl else {
            return
        }

        impl()
    }
}
