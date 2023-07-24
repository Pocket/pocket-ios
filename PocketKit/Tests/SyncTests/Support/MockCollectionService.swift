// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync

class MockCollectionService: CollectionService {
    var implementations: [String: Any] = [:]
    var calls: [String: [Any]] = [:]
}

extension MockCollectionService {
    static let fetchCollection = "fetchCollection"
    typealias FetchCollectionImpl = (String) async throws -> Sync.CollectionModel

    struct FetchCollectionCall {
        let slug: String
    }

    func stubFetchSlateLineup(impl: @escaping FetchCollectionImpl) {
        implementations[Self.fetchCollection] = impl
    }

    func fetchCollection(by slug: String) async throws -> Sync.CollectionModel {
        guard let impl = implementations[Self.fetchCollection] as? FetchCollectionImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchCollection] = (calls[Self.fetchCollection] ?? []) + [
            FetchCollectionCall(slug: slug)
        ]

        return try await impl(slug)
    }

    func fetchCollectionCall(at index: Int) -> FetchCollectionCall? {
        guard let calls = calls[Self.fetchCollection],
              calls.count > index,
              let call = calls[index] as? FetchCollectionCall else {
                  return nil
              }

        return call
    }
}
