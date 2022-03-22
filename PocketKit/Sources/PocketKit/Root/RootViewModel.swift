import Foundation
import Analytics
import Sync
import Combine
import Textile
import SharedPocketKit


class RootViewModel {
    @Published
    var isLoggedIn = false

    private let appSession: AppSession
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    private var subscriptions: Set<AnyCancellable> = []

    init(
        appSession: AppSession,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults

        appSession.$currentSession.sink { session in
            if let session = session {
                self.setUpSession(session)
                self.isLoggedIn = true
            } else {
                self.tearDownSession()
                self.isLoggedIn = false
            }
        }.store(in: &subscriptions)
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])
        tracker.addPersistentContext(UserContext(guid: session.guid, userID: session.userIdentifier))
        source.refresh()
    }

    private func tearDownSession() {
        source.clear()

        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        Crashlogger.clearUser()
        Textiles.clearImageCache()
    }
}
