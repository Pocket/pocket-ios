import AuthenticationServices


protocol AuthenticationSession {
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }
    var prefersEphemeralWebBrowserSession: Bool { get set }

    init(url URL: URL, callbackURLScheme: String?, completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler)

    func start() -> Bool
}

extension ASWebAuthenticationSession: AuthenticationSession { }
