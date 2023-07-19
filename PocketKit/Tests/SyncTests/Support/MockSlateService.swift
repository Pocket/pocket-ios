// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync

class MockSlateService: SlateService {
    var implementations: [String: Any] = [:]
    var calls: [String: [Any]] = [:]
}

extension MockSlateService {
    static let fetchSlateLineup = "fetchSlateLineup"
    typealias FetchSlateLineupImpl = (String) async throws -> Void

    struct FetchSlateLineupCall {
        let identifier: String
    }

    func stubFetchSlateLineup(impl: @escaping FetchSlateLineupImpl) {
        implementations[Self.fetchSlateLineup] = impl
    }

    func fetchHomeSlateLineup() async throws {
        guard let impl = implementations[Self.fetchSlateLineup] as? FetchSlateLineupImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchSlateLineup] = (calls[Self.fetchSlateLineup] ?? []) + [
            FetchSlateLineupCall(identifier: "")
        ]

        try await impl("")
    }

    func fetchSlateLineupCall(at index: Int) -> FetchSlateLineupCall? {
        guard let calls = calls[Self.fetchSlateLineup],
              calls.count > index,
              let call = calls[index] as? FetchSlateLineupCall else {
                  return nil
              }

        return call
    }
}

extension MockSlateService {
    static let fetchSlate = "fetchSlate"
    typealias FetchSlateImpl = (String) async throws -> Void

    struct FetchSlateCall {
        let identifier: String
    }

    func stubFetchSlate(impl: @escaping FetchSlateImpl) {
        implementations[Self.fetchSlate] = impl
    }

    func fetchSlate(_ slateID: String) async throws {
        guard let impl = implementations[Self.fetchSlate] as? FetchSlateImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchSlate] = (calls[Self.fetchSlate] ?? []) + [
            FetchSlateCall(identifier: slateID)
        ]

        try await impl(slateID)
    }

    func fetchSlateCall(at index: Int) -> FetchSlateCall? {
        guard let calls = calls[Self.fetchSlate],
              calls.count > index,
              let call = calls[index] as? FetchSlateCall else {
                  return nil
              }

        return call
    }
}
