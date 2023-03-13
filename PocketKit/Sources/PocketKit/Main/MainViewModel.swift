import Combine
import Network
import Sync
import Foundation
import BackgroundTasks
import UIKit

@MainActor
class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .home

    @Published
    var isCollapsed = UIDevice.current.userInterfaceIdiom == .phone

    let home: HomeViewModel
    let saves: SavesContainerViewModel
    let account: AccountViewModel

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
                ) { tracker, source in
                    PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: tracker, source: source)
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
                premiumUpgradeViewModelFactory: { tracker, source in
                    PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: tracker, source: source)
                }
            )
        )
    }

    init(
        saves: SavesContainerViewModel,
        home: HomeViewModel,
        account: AccountViewModel
    ) {
        self.saves = saves
        self.home = home
        self.account = account
    }

    enum Subsection {
        case saves
        case archive
    }

    enum AppSection: CaseIterable, Identifiable, Hashable {
        static var allCases: [MainViewModel.AppSection] {
            return [.home, .saves(nil), .account]
        }

        case home
        case saves(Subsection?)
        case account

        var navigationTitle: String {
            switch self {
            case .home:
                return L10n.home
            case .saves:
                return L10n.saves
            case .account:
                return L10n.settings
            }
        }

        var id: AppSection {
            return self
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

    func navigationSidebarCellViewModel(for appSection: AppSection) -> NavigationSidebarCellViewModel {
        let isSelected: Bool = {
            switch (selectedSection, appSection) {
            case (.home, .home), (.saves, .saves), (.account, .account):
                return true
            default:
                return false
            }
        }()

        return NavigationSidebarCellViewModel(
            section: appSection,
            isSelected: isSelected
        )
    }
}
