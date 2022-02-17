import Sync
import Analytics
import Foundation
import Textile


protocol SessionController {
    var isSignedIn: Bool { get }

    func signOut()
    func updateSession(_ session: Session?)
    func clearSession()
}
class PocketSessionController: SessionController {
    private let authClient: AuthorizationClient
    private let session: AppSession
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    init(
        authClient: AuthorizationClient,
        session: AppSession,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults
    ) {
        self.authClient = authClient
        self.session = session
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults
    }

    var isSignedIn: Bool {
        session.currentSession != nil
    }

    func signOut() {
        session.currentSession = nil

        source.clear()
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        Crashlogger.clearUser()
        Textiles.clearImageCache()
    }

    func updateSession(_ session: Session?) {
        self.session.currentSession = session
    }

    func clearSession() {
        session.currentSession = nil
    }
}
