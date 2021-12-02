import Combine
import Sync
import Analytics

enum PocketEvent {
    case signedIn
    case signedOut
}

typealias PocketEvents = PassthroughSubject<PocketEvent, Never>


class RootViewModel: ObservableObject {
    @Published
    private(set) var state: State
    private let events: PocketEvents
    private var subscriptions: [AnyCancellable] = []

    // Needed so we can build a MainViewModel or SignInViewModel
    // TODO: Use a proper dependency injection strategy to eliminate need to
    // keep track of transient dependencies
    private let refreshCoordinator: RefreshCoordinator
    private let authClient: AuthorizationClient
    private let session: Session
    private let accessTokenStore: AccessTokenStore
    private let tracker: Tracker

    init(
        state: State,
        events: PocketEvents,
        refreshCoordinator: RefreshCoordinator,
        authClient: AuthorizationClient,
        session: Session,
        accessTokenStore: AccessTokenStore,
        tracker: Tracker
    ) {
        self.state = state
        self.events = events

        self.refreshCoordinator = refreshCoordinator
        self.authClient = authClient
        self.session = session
        self.accessTokenStore = accessTokenStore
        self.tracker = tracker

        events.sink { [weak self] event in
            self?.handle(event)
        }.store(in: &subscriptions)
    }

    private func handle(_ event: PocketEvent) {
        switch event {
        case .signedIn:
            state = .main(MainViewModel(refreshCoordinator: refreshCoordinator))
        case .signedOut:
            state = .signIn(SignInViewModel(
                authClient: authClient,
                session: session,
                accessTokenStore: accessTokenStore,
                tracker: tracker,
                events: events
            ))
        }
    }
}

extension RootViewModel {
    enum State {
        case signIn(SignInViewModel)
        case main(MainViewModel)
    }
}
