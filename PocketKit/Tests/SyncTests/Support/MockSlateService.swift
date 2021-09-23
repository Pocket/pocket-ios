// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync


class MockSlateService: SlateService {
    typealias FetchSlatesImpl = () async throws -> [Slate]

    private var fetchSlatesImpl: FetchSlatesImpl?

    func stubFetchSlates(impl: @escaping FetchSlatesImpl) {
        fetchSlatesImpl = impl
    }

    func fetchSlates() async throws -> [Slate] {
        guard let impl = fetchSlatesImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return try await impl()
    }


}
