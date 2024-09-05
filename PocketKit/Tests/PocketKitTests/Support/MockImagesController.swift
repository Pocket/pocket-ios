// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync

class MockImagesController: ImagesController {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var delegate: ImagesControllerDelegate?

    var images: [CDImage]?
}

extension MockImagesController {
    static let performFetch = "performFetch"
    typealias PerformFetchImpl = () -> Void
    struct PerformFetchCall { }

    func stubPerformFetch(impl: @escaping PerformFetchImpl) {
        implementations[Self.performFetch] = impl
    }

    func performFetch() throws {
        guard let impl = implementations[Self.performFetch] as? PerformFetchImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.performFetch] = (calls[Self.performFetch] ?? []) + [PerformFetchCall()]

        impl()
    }

    func performFetchCall(at index: Int) -> PerformFetchCall? {
        guard let calls = calls[Self.performFetch], calls.count > index else {
            return nil
        }

        return calls[index] as? PerformFetchCall
    }
}
