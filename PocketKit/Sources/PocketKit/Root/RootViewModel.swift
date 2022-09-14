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

        appSession.$currentSession.sink { session in
            if let session = session {
                self.setUpSession(session)
                self.isLoggedIn = true
            } else {
                self.tearDownSession()
                self.isLoggedIn = false
            }
        }.store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).delay(for: 0.5, scheduler: RunLoop.main).sink { [weak self] _ in
            self?.showSaveFromClipboardBanner()
        }.store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            self?.bannerViewModel = nil
        }.store(in: &subscriptions)
    }

    func showSaveFromClipboardBanner() {
        if UIPasteboard.general.hasURLs, isLoggedIn {

            bannerViewModel = BannerViewModel(
                prompt: "Add copied URL to your Saves?",
                backgroundColor: UIColor(.ui.teal6),
                borderColor: UIColor(.ui.teal5),
                primaryAction: { [weak self] itemProviders in
                    self?.handleBannerPrimaryAction(itemProviders: itemProviders)
                },
                dismissAction: { [weak self] in
                    self?.bannerViewModel = nil
                }
            )
        }
    }

    private func handleBannerPrimaryAction(itemProviders: [NSItemProvider]) {
        bannerViewModel = nil

        for provider in itemProviders {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { [weak self] url, error in
                    guard let url = url else {
                        return
                    }

                    self?.source.save(url: url)
                }
            }
        }
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        tracker.resetPersistentContexts([
            APIUserContext(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])
        tracker.addPersistentContext(UserContext(guid: session.guid, userID: session.userIdentifier))
        Crashlogger.setUserID(session.userIdentifier)
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
