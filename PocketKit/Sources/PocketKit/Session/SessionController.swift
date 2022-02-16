import Sync
import Analytics
import Foundation
import Textile


class SessionController {

    private let authClient: AuthorizationClient
    private let session: Session
    private let accessTokenStore: AccessTokenStore
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    init(
        authClient: AuthorizationClient,
        session: Session,
        accessTokenStore: AccessTokenStore,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults
    ) {
        self.authClient = authClient
        self.session = session
        self.accessTokenStore = accessTokenStore
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults
    }

    var isSignedIn: Bool {
        session.userID != nil
        && session.guid != nil
        && accessTokenStore.accessToken != nil
    }

    func clearAccessToken() {
        try? accessTokenStore.delete()
    }

    func signOut() {
        clearAccessToken()

        source.clear()
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])
        session.userID = nil
        session.guid = nil

        Crashlogger.clearUser()
        Textiles.clearImageCache()
    }

    func updateSession(
        accessToken: String?,
        guid: String?,
        userID: String?
    ) {
        if let accessToken = accessToken {
            try? accessTokenStore.save(token: accessToken)
        }

        if let guid = guid {
            session.guid = guid
        }

        if let userID = userID {
            session.userID = userID
        }
    }
}
