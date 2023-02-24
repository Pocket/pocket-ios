import Foundation
import Analytics
import Sync
import Combine
import Textile
import SharedPocketKit
import UIKit

class RootViewModel {
    @Published
    var isLoggedIn = false

    @Published
    var bannerViewModel: BannerViewModel?

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

        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] notification in
            self?.handleSession(session: notification.object as? SharedPocketKit.Session)
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
        source.refresh()
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
