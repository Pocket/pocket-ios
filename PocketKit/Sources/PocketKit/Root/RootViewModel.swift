import Combine
import Sync
import Analytics
import Foundation

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
    private let sessionController: SessionController
    private let refreshCoordinator: RefreshCoordinator
    private let source: Source
    private let tracker: Tracker

    init(
        state: State,
        events: PocketEvents,
        refreshCoordinator: RefreshCoordinator,
        sessionController: SessionController,
        source: Source,
        tracker: Tracker
    ) {
        self.state = state
        self.events = events
        self.refreshCoordinator = refreshCoordinator
        self.sessionController = sessionController
        self.source = source
        self.tracker = tracker

        events.sink { [weak self] event in
            self?.handle(event)
        }.store(in: &subscriptions)
    }

    private func handle(_ event: PocketEvent) {
        switch event {
        case .signedIn:
            state = .main(
                MainViewModel(
                    refreshCoordinator: refreshCoordinator,
                    myList: MyListContainerViewModel(
                        savedItemsList: SavedItemsListViewModel(source: source, tracker: tracker),
                        archivedItemsList: ArchivedItemsListViewModel(source: source, tracker: tracker)
                    ),
                    home: HomeViewModel(),
                    settings: SettingsViewModel(sessionController: sessionController, events: events)
                )
            )
        case .signedOut:
            state = .signIn(
                SignInViewModel(
                    sessionController: sessionController,
                    events: events
                )
            )
        }
    }
}

extension RootViewModel {
    enum State {
        case signIn(SignInViewModel)
        case main(MainViewModel)
    }
}
