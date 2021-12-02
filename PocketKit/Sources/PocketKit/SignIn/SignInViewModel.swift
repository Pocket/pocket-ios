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

    private let authClient: AuthorizationClient
    private let session: Session
    private let accessTokenStore: AccessTokenStore
    private let tracker: Tracker

    private let events: PocketEvents

    init(
        authClient: AuthorizationClient,
        session: Session,
        accessTokenStore: AccessTokenStore,
        tracker: Tracker,
        events: PocketEvents
    ) {
        self.authClient = authClient
        self.session = session
        self.accessTokenStore = accessTokenStore
        self.tracker = tracker
        self.events = events
    }

    func signIn() {
        Task {
            do {
                let guid = try await authClient.requestGUID()
                let authResponse = try await authClient.authorize(
                    guid: guid,
                    username: username,
                    password: password
                )
                let userID = authResponse.account.userID

                session.guid = guid
                session.userID = userID
                try accessTokenStore.save(token: authResponse.accessToken)

                let user = UserContext(guid: guid, userID: userID)
                tracker.addPersistentContext(user)
                Crashlogger.setUserID(userID)

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
