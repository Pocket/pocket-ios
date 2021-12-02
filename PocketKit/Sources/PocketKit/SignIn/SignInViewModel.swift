import Combine
import Sync
import Analytics


class SignInViewModel: ObservableObject {
    @Published
    var username: String = ""

    @Published
    var password: String = ""

    @Published
    var error: SignInError?

    private let sessionController: SessionController
    private let events: PocketEvents

    init(
        sessionController: SessionController,
        events: PocketEvents
    ) {
        self.sessionController = sessionController
        self.events = events
    }

    func signIn() {
        Task {
            do {
                try await sessionController.signIn(
                    username: username,
                    password: password
                )

                events.send(.signedIn)
            } catch(let signInError) {
                self.error = SignInError.signInError(signInError)
                Crashlogger.capture(error: signInError)
            }
        }
    }
}

extension SignInViewModel {
    enum SignInError: Error, Identifiable {
        case signInError(Error)

        var localizedDescription: String {
            switch self {
            case .signInError(let error):
                return error.localizedDescription
            }
        }

        var id: String {
            return "\(self)"
        }
    }
}
