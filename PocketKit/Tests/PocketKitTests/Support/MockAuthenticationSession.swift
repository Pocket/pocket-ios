// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import PocketKit
import AuthenticationServices

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

class MockAuthenticationSession: AuthenticationSession {
    private var implementations: [String: Any] = [:]

    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    var prefersEphemeralWebBrowserSession = false

    var completionHandler: ASWebAuthenticationSession.CompletionHandler?
    var url: URL?
    var error: Error?

    required init() { }
}

extension MockAuthenticationSession {
    static let start = "start"
    typealias StartImpl = () -> Bool

    struct StartCall { }

    func stubStart(_ impl: @escaping StartImpl) {
        implementations[Self.start] = impl
    }

    func start() -> Bool {
        guard let impl = implementations[Self.start] as? StartImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return impl()
    }
}
