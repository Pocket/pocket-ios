// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Network
import Sync
import Foundation
import BackgroundTasks
import UIKit
import Textile
import Localization

@MainActor
class MainViewModel: ObservableObject {
    let home: HomeViewModel
    let saves: SavesContainerViewModel
    let account: AccountViewModel
    let source: Source
    private var linkRouter: LinkRouter

    @Published var selectedSection: AppSection = .home

    @Published var showBanner: Bool = false

    private var subscriptions: Set<AnyCancellable> = []
    private let userDefaults: UserDefaults

    convenience init() {
        self.init(
            saves: SavesContainerViewModel(
                tracker: Services.shared.tracker,
                searchList: DefaultSearchViewModel(
                    networkPathMonitor: NWPathMonitor(),
                    user: Services.shared.user,
                    userDefaults: Services.shared.userDefaults,
                    featureFlags: Services.shared.featureFlagService,
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.search),
                    store: Services.shared.subscriptionStore,
                    notificationCenter: Services.shared.notificationCenter
                ) { source in
                    PremiumUpgradeViewModel(
                        store: Services.shared.subscriptionStore,
                        tracker: Services.shared.tracker,
                        source: source,
                        networkPathMonitor: NWPathMonitor()
                    )
                },
                savedItemsList: SavedItemsListViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.saves),
                    viewType: .saves,
                    listOptions: .saved(userDefaults: Services.shared.userDefaults),
                    notificationCenter: .default,
                    user: Services.shared.user,
                    store: Services.shared.subscriptionStore,
                    refreshCoordinator: Services.shared.savesRefreshCoordinator,
                    networkPathMonitor: NWPathMonitor(),
                    userDefaults: Services.shared.userDefaults,
                    featureFlags: Services.shared.featureFlagService
                ),
                archivedItemsList: SavedItemsListViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.archive),
                    viewType: .archive,
                    listOptions: .archived(userDefaults: Services.shared.userDefaults),
                    notificationCenter: .default,
                    user: Services.shared.user,
                    store: Services.shared.subscriptionStore,
                    refreshCoordinator: Services.shared.archiveRefreshCoordinator,
                    networkPathMonitor: NWPathMonitor(),
                    userDefaults: Services.shared.userDefaults,
                    featureFlags: Services.shared.featureFlagService
                ),
                addSavedItemModel: AddSavedItemViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.saves)
                )
            ),
            home: HomeViewModel(
                source: Services.shared.source,
                tracker: Services.shared.tracker.childTracker(hosting: .home.screen),
                networkPathMonitor: NWPathMonitor(),
                homeRefreshCoordinator: Services.shared.homeRefreshCoordinator,
                user: Services.shared.user,
                store: Services.shared.subscriptionStore,
                recentSavesWidgetUpdateService: Services.shared.recentSavesWidgetUpdateService,
                recommendationsWidgetUpdateService: Services.shared.recommendationsWidgetUpdateService,
                userDefaults: Services.shared.userDefaults,
                notificationCenter: Services.shared.notificationCenter,
                featureFlags: Services.shared.featureFlagService
            ),
            account: AccountViewModel(
                appSession: Services.shared.appSession,
                user: Services.shared.user,
                tracker: Services.shared.tracker,
                userDefaults: Services.shared.userDefaults,
                userManagementService: Services.shared.userManagementService,
                notificationCenter: .default,
                networkPathMonitor: NWPathMonitor(),
                restoreSubscription: {
                    try await Services.shared.subscriptionStore.restoreSubscription()
                },
                premiumUpgradeViewModelFactory: { source in
                    PremiumUpgradeViewModel(
                        store: Services.shared.subscriptionStore,
                        tracker: Services.shared.tracker,
                        source: source,
                        networkPathMonitor: NWPathMonitor()
                    )
                },
                premiumStatusViewModelFactory: {
                    PremiumStatusViewModel(service: PocketSubscriptionInfoService(client: Services.shared.v3Client), tracker: Services.shared.tracker)
                },
                featureFlags: Services.shared.featureFlagService
            ),
            source: Services.shared.source,
            userDefaults: Services.shared.userDefaults,
            linkRouter: LinkRouter()
        )
        let routingAction: (String, ReadableSource) -> Void = { [weak self] urlString, source in
            // dismiss any existing modal
            self?.account.dismissAll()
            // go to home
            self?.selectedSection = .home
            guard let item = self?.source.fetchViewContextItem(urlString) else {
                return
            }
            // show the item associated to the given URL
            if let savedItem = item.savedItem {
                self?.home.select(savedItem: savedItem, readableSource: source)
            } else if let recommendation = item.recommendation {
                self?.home.select(recommendation: recommendation, readableSource: source)
            }
        }

        let widgetRoute = WidgetRoute(action: routingAction)
        let collectionRoute = CollectionRoute(action: routingAction)
        linkRouter.addRoute(route: widgetRoute)
        linkRouter.addRoute(route: collectionRoute)
    }

    init(
        saves: SavesContainerViewModel,
        home: HomeViewModel,
        account: AccountViewModel,
        source: Source,
        userDefaults: UserDefaults,
        linkRouter: LinkRouter
    ) {
        self.saves = saves
        self.home = home
        self.account = account
        self.source = source
        self.userDefaults = userDefaults
        self.linkRouter = linkRouter

        self.loadStartingAppSection()
        self.clearStartingAppSection()

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            self?.saveStartingAppSection()
        }.store(in: &subscriptions)
    }

    enum AppSection: CaseIterable, Identifiable, Hashable {
        static var allCases: [MainViewModel.AppSection] {
            return [.home, .saves, .account]
        }

        case home
        case saves
        case account

        init(from rawValue: String?) {
            switch rawValue {
            case AppSection.saves.id:
                self = .saves
            case AppSection.account.id:
                self = .account
            default:
                self = .home
            }
        }

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

    // MARK: Tab Restoration

    private func loadStartingAppSection() {
        let selectedSectionID = userDefaults.string(forKey: UserDefaults.Key.startingAppSection)
        selectedSection = AppSection(from: selectedSectionID)
    }

    private func saveStartingAppSection() {
        userDefaults.setValue(selectedSection.id, forKey: UserDefaults.Key.startingAppSection)
    }

    private func clearStartingAppSection() {
        userDefaults.removeObject(forKey: UserDefaults.Key.startingAppSection)
    }
}

extension MainViewModel {
    @MainActor
    func handle(_ url: URL) {
        linkRouter.matchRoute(from: url)
    }
}
