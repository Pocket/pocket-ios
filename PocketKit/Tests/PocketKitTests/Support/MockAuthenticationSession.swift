@testable import PocketKit
import AuthenticationServices


class MockAuthenticationSession: AuthenticationSession {
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    var prefersEphemeralWebBrowserSession = false

    let url: URL
    let scheme: String?
    let completionHandler: ASWebAuthenticationSession.CompletionHandler?
    required init(url URL: URL, callbackURLScheme: String?, completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler) {
        self.url = URL
        self.scheme = callbackURLScheme
        self.completionHandler = completionHandler
    }

    var startCalls = 0
    func start() -> Bool {
        startCalls += 1
        completionHandler?(URL(string: "\(scheme!)://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!, nil)
        return true
    }
}

class MockErrorAuthenticationSession: AuthenticationSession {
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    var prefersEphemeralWebBrowserSession = false

    let url: URL
    let scheme: String?
    let completionHandler: ASWebAuthenticationSession.CompletionHandler?
    required init(url URL: URL, callbackURLScheme: String?, completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler) {
        self.url = URL
        self.scheme = callbackURLScheme
        self.completionHandler = completionHandler
    }

    var startCalls = 0
    func start() -> Bool {
        startCalls += 1
        completionHandler?(nil, FakeError.error)
        return true
    }
}
