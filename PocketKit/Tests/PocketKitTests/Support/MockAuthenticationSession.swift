@testable import PocketKit
import AuthenticationServices


class MockAuthenticationSession: AuthenticationSession {
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    var prefersEphemeralWebBrowserSession = false

    var completionHandler: ASWebAuthenticationSession.CompletionHandler?
    var url: URL?
    var error: Error?

    required init() { }

    func start() -> Bool {
        completionHandler?(url, error)
        return true
    }
}
