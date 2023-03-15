import Foundation
import Analytics
import Sync
import Combine
import Textile
import SharedPocketKit
import UIKit

@MainActor
class RootViewModel: ObservableObject {
    @Published
    var isLoggedIn = false

    @Published
    var bannerViewModel: BannerViewModel?

    @Published
    var mainViewModel: MainViewModel

    @Published
    var loggedOutViewModel: LoggedOutViewModel

    private let appSession: AppSession
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults

    private var subscriptions: Set<AnyCancellable> = []

    convenience init() {
        self.init(appSession: Services.shared.appSession, tracker: Services.shared.tracker, source: Services.shared.source, userDefaults: .standard, mainViewModel: MainViewModel(), loggedOutViewModel: LoggedOutViewModel())
    }

    init(
        appSession: AppSession,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults,
        mainViewModel: MainViewModel,
        loggedOutViewModel: LoggedOutViewModel
    ) {
        self.appSession = appSession
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults
        self.mainViewModel = mainViewModel
        self.loggedOutViewModel = loggedOutViewModel

        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] notification in
            self?.handleSession(session: notification.object as? SharedPocketKit.Session)
            guard (notification.object as? SharedPocketKit.Session) != nil else {
                return
            }
            // Call refresh on login of the app.
            source.refreshSaves()
            source.refreshArchive()
        }.store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] notification in
            self?.handleSession(session: nil)
        }.store(in: &subscriptions)

        // Because session could already be available at init, lets try and use it.
        handleSession(session: appSession.currentSession)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).delay(for: 0.5, scheduler: RunLoop.main).sink { [weak self] _ in
            self?.showSaveFromClipboardBanner()
        }.store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            self?.bannerViewModel = nil
        }.store(in: &subscriptions)
    }

    /**
     Handles a session if it exists.
     */
    func handleSession(session: SharedPocketKit.Session?) {
        guard let session = session else {
            // If the session is nil, ensure the user's view is logged out
            self.tearDownSession()
            self.isLoggedIn = false
            return
        }

        // We have a session! Ensure the user is logged in.
        self.setUpSession(session)
        self.isLoggedIn = true
    }

    func showSaveFromClipboardBanner() {
        if UIPasteboard.general.hasURLs, isLoggedIn {
            bannerViewModel = BannerViewModel(
                prompt: L10n.addCopiedURLToYourSaves,
                buttonText: L10n.saves,
                backgroundColor: UIColor(.ui.teal6),
                borderColor: UIColor(.ui.teal5),
                primaryAction: { [weak self] url in
                    self?.handleBannerPrimaryAction(url: url)
                },
                dismissAction: { [weak self] in
                    self?.bannerViewModel = nil
                }
            )
        }
    }

    private func handleBannerPrimaryAction(url: URL?) {
        bannerViewModel = nil

        guard let url = url else { return }
        source.save(url: url)
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])
        tracker.addPersistentEntity(UserEntity(guid: session.guid, userID: session.userIdentifier))
        Log.setUserID(session.userIdentifier)
    }

    private func tearDownSession() {
        source.clear()

        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        Log.clearUser()
        Textiles.clearImageCache()
    }
}
