import Sync
import Analytics
import Foundation
import Textile
import Combine


class SessionListener {
    private let appSession: AppSession
    private let authClient: AuthorizationClient
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    private var subscriptions: Set<AnyCancellable> = []

    init(
        appSession: AppSession,
        authClient: AuthorizationClient,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
        self.authClient = authClient
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults

        appSession.$currentSession.sink { session in
            if let session = session {
                tracker.addPersistentContext(UserContext(guid: session.guid, userID: session.userIdentifier))
            } else {
                source.clear()
                userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                tracker.resetPersistentContexts([
                    APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
                ])

                Crashlogger.clearUser()
                Textiles.clearImageCache()
            }
        }.store(in: &subscriptions)
    }
}
