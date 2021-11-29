import Sync
import Analytics
import Textile
import Foundation


class SettingsViewModel {
    private let authClient: AuthorizationClient
    private let session: Session
    private let accessTokenStore: AccessTokenStore
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    private let events: PocketEvents

    init(
        authClient: AuthorizationClient,
        session: Session,
        accessTokenStore: AccessTokenStore,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults,
        events: PocketEvents
    ) {
        self.authClient = authClient
        self.session = session
        self.accessTokenStore = accessTokenStore
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults

        self.events = events
    }

    func signOut() {
        Crashlogger.clearUser()
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])
        session.userID = nil
        session.guid = nil
        try? accessTokenStore.delete()
        source.clear()
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        Textiles.clearImageCache()

        events.send(.signedOut)
    }
}
