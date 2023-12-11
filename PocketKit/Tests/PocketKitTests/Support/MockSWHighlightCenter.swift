// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedWithYou
@testable import PocketKit
@testable import Sync

class MockSWHighlightCenter: SWHighlightCenterProtocol {
    var highlights: [SWHighlight] = []
    var delegate: SWHighlightCenterDelegate?
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - highlightFor
extension MockSWHighlightCenter {
    static let highlightFor = "highlightFor"

    typealias HighlightForImpl = (URL) -> SWHighlight

    struct HighlightForCall {
        let url: URL
    }

    func stubHighlightFor(impl: @escaping HighlightForImpl) {
        implementations[Self.highlightFor] = impl
    }

    func highlight(for URL: URL) async throws -> SWHighlight {
        guard let impl = implementations[Self.highlightFor] as? HighlightForImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.highlightFor] = (calls[Self.highlightFor] ?? []) + [
            HighlightForCall(url: URL)
        ]

        return impl(URL)
    }

    func highlightForCall(at index: Int) -> HighlightForCall? {
        guard let calls = calls[Self.highlightFor], calls.count > index,
              let call = calls[index] as? HighlightForCall else {
                  return nil
              }

        return call
    }
}

extension MockSWHighlightCenter {
    static let getHighlightFor = "getHighlightFor"

    typealias GetHighlightForImpl = (URL, ((SWHighlight?, Error?) -> Void)) -> Void

    struct GetHighlightForCall {
        let url: URL
        let completionHandler: (SWHighlight?, Error?) -> Void
    }

    func stubGetHighlightFor(impl: @escaping HighlightForImpl) {
        implementations[Self.getHighlightFor] = impl
    }

    func getHighlightFor(_ URL: URL, completionHandler: @escaping (SWHighlight?, Error?) -> Void) {
        guard let impl = implementations[Self.getHighlightFor] as? GetHighlightForImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.getHighlightFor] = (calls[Self.getHighlightFor] ?? []) + [
            GetHighlightForCall(url: URL, completionHandler: completionHandler)
        ]

        return impl(URL, completionHandler)
    }

    func getHighlightForCall(at index: Int) -> GetHighlightForCall? {
        guard let calls = calls[Self.getHighlightFor], calls.count > index,
              let call = calls[index] as? GetHighlightForCall else {
                  return nil
              }

        return call
    }
}
