import AuthenticationServices


protocol AuthenticationSession {
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }
    var prefersEphemeralWebBrowserSession: Bool { get set }

    func start() -> Bool
}

extension ASWebAuthenticationSession: AuthenticationSession { }
