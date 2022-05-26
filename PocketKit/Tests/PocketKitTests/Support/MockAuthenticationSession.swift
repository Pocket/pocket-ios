@testable import PocketKit
import AuthenticationServices


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
