import Combine
import Network
import Sync
import Foundation
import BackgroundTasks
import UIKit
import Textile

@MainActor
class MainViewModel: ObservableObject {
    let home: HomeViewModel
    let saves: SavesContainerViewModel
    let account: AccountViewModel
    let source: Source

    @Published
    var selectedSection: AppSection = .home

    @Published
    var bannerViewModel: PasteBoardModifier.PasteBoardData?

    @Published
    var showBanner: Bool = false

    private var subscriptions: Set<AnyCancellable> = []

    @MainActor
    convenience init() {
        self.init(
            saves: SavesContainerViewModel(
                searchList: SearchViewModel(
                    networkPathMonitor: NWPathMonitor(),
                    user: Services.shared.user,
                    userDefaults: Services.shared.userDefaults,
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.search)
                ) { source in
                    PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: Services.shared.tracker, source: source)
                },
                savedItemsList: SavedItemsListViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.saves),
                    viewType: .saves,
                    listOptions: .saved,
                    notificationCenter: .default
                ),
                archivedItemsList: SavedItemsListViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.archive),
                    viewType: .archive,
                    listOptions: .archived,
                    notificationCenter: .default
                )
            ),
            home: HomeViewModel(
                source: Services.shared.source,
                tracker: Services.shared.tracker.childTracker(hosting: .home.screen),
                networkPathMonitor: NWPathMonitor(),
                homeRefreshCoordinator: Services.shared.homeRefreshCoordinator
            ),
            account: AccountViewModel(
                appSession: Services.shared.appSession,
                user: Services.shared.user,
                tracker: Services.shared.tracker,
                userDefaults: Services.shared.userDefaults,
                userManagementService: Services.shared.userManagementService,
                notificationCenter: .default,
                restoreSubscription: {
                    try await Services.shared.subscriptionStore.restoreSubscription()
                },
                premiumUpgradeViewModelFactory: { source in
                    PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: Services.shared.tracker, source: source)
                },
                premiumStatusViewModelFactory: {
                    PremiumStatusViewModel(service: PocketSubscriptionInfoService(client: Services.shared.v3Client), tracker: Services.shared.tracker)
                }
            ),
            source: Services.shared.source
        )
    }

    init(
        saves: SavesContainerViewModel,
        home: HomeViewModel,
        account: AccountViewModel,
        source: Source
    ) {
        self.saves = saves
        self.home = home
        self.account = account
        self.source = source

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).delay(for: 0.5, scheduler: RunLoop.main).sink { [weak self] _ in
            self?.showSaveFromClipboardBanner()
        }.store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            self?.bannerViewModel = nil
        }.store(in: &subscriptions)
    }

    enum AppSection: CaseIterable, Identifiable, Hashable {
        static var allCases: [MainViewModel.AppSection] {
            return [.home, .saves, .account]
        }

        case home
        case saves
        case account

        var id: String {
            switch self {
            case .home:
                return "home"
            case .saves:
                return "saves"
            case .account:
                return "account"
            }
        }
    }

    func clearRecommendationToReport() {
        home.clearRecommendationToReport()
    }

    func clearSharedActivity() {
        home.clearSharedActivity()
        saves.clearSharedActivity()
    }

    func clearIsPresentingReaderSettings() {
        home.clearIsPresentingReaderSettings()
        saves.clearIsPresentingReaderSettings()
    }

    func clearPresentedWebReaderURL() {
        home.clearPresentedWebReaderURL()
        saves.clearPresentedWebReaderURL()
    }

    func selectSavesTab() {
        self.selectedSection = .saves
    }

    func showSaveFromClipboardBanner() {
        if UIPasteboard.general.hasURLs {
            bannerViewModel = PasteBoardModifier.PasteBoardData(title: L10n.addCopiedURLToYourSaves, action: PasteBoardModifier.PasteBoardData.PasteBoardAction(text: L10n.saves, action: { [weak self] url in
                self?.handleBannerPrimaryAction(url: url)
            }, dismiss: { [weak self] in
                self?.bannerViewModel = nil
            }))
        }
    }

    private func handleBannerPrimaryAction(url: URL?) {
        bannerViewModel = nil

        guard let url = url else { return }
        source.save(url: url)
    }
}
