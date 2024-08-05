// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Network
@preconcurrency import Sync
import Foundation
import BackgroundTasks
import UIKit
import Textile
import Localization
import CoreSpotlight
import SharedPocketKit

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
                    notificationCenter: Services.shared.notificationCenter,
                    accessService: Services.shared.accessService
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
                    featureFlags: Services.shared.featureFlagService,
                    accessService: Services.shared.accessService
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
                    featureFlags: Services.shared.featureFlagService,
                    accessService: Services.shared.accessService
                ),
                addSavedItemModel: AddSavedItemViewModel(
                    source: Services.shared.source,
                    tracker: Services.shared.tracker.childTracker(hosting: .saves.saves)
                ),
                accessService: Services.shared.accessService
            ),
            home: HomeViewModel(
                source: Services.shared.source,
                tracker: Services.shared.tracker.childTracker(hosting: .home.screen),
                appsession: Services.shared.appSession,
                accessService: Services.shared.accessService,
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
                accessService: Services.shared.accessService,
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
        setupLinkRouter()
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

// MARK: Universal Links
extension MainViewModel {
    @MainActor
    func handle(_ url: URL) {
        linkRouter.matchRoute(from: url)
    }

    @MainActor
    func handleSpotlight(_ userActivity: NSUserActivity) {
        guard let uriRepresentation = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              let uri = URL(string: uriRepresentation),
              let objectID = source.objectID(from: uri),
              let savedItem = source.viewObject(id: objectID) as? SavedItem else {
            return
        }
        var components = URLComponents()
        components.scheme = "spotlight"
        components.path = "/itemURL"
        components.queryItems = [URLQueryItem(name: "url", value: savedItem.url)]
        linkRouter.matchRoute(from: components.url!)
    }

    private func setupLinkRouter() {
        let fallbackAction: (URL) -> Void = { url in
            UIApplication.shared.open(url)
        }
        linkRouter.setFallbackAction(fallbackAction)

        let routingAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            // dismiss any existing modal
            self?.account.dismissAll()
            // go to home
            self?.selectedSection = .home
            Task {
                do {
                    if let item = try await self?.source.fetchViewItem(from: url.absoluteString) {
                        if let savedItem = item.savedItem {
                            self?.home.select(savedItem: savedItem, readableSource: source)
                        } else if let recommendation = item.recommendation {
                            self?.home.select(recommendation: recommendation, readableSource: source)
                        } else {
                            self?.home.select(externalItem: item)
                        }
                    } else {
                        fallbackAction(url)
                    }
                } catch {
                    fallbackAction(url)
                }
            }
        }

        let shortUrlRoutingAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            // dismiss any existing modal
            self?.account.dismissAll()
            // go to home
            self?.selectedSection = .home
            Task {
                do {
                    if let item = try await self?.source.fetchShortUrlViewItem(url.absoluteString) {
                        if let savedItem = item.savedItem {
                            self?.home.select(savedItem: savedItem, readableSource: source)
                        } else if let recommendation = item.recommendation {
                            self?.home.select(recommendation: recommendation, readableSource: source)
                        } else {
                            self?.home.select(externalItem: item)
                        }
                    } else {
                        fallbackAction(url)
                    }
                } catch {
                    fallbackAction(url)
                }
            }
        }

        let pocketShareUrlRoutingAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            // dismiss any existing modal
            self?.account.dismissAll()
            // go to home
            self?.selectedSection = .home
            // extract the slug
            guard let slug = url.pathComponents[safe: 2] else {
                Log.capture(message: "Unable to extract slug")
                fallbackAction(url)
                return
            }
            Task {
                do {
                    if let item = try await self?.source.item(by: slug) {
                        if let savedItem = item.savedItem {
                            self?.home.select(savedItem: savedItem, readableSource: source)
                        } else if let recommendation = item.recommendation {
                            self?.home.select(recommendation: recommendation, readableSource: source)
                        } else {
                            self?.home.select(externalItem: item)
                        }
                    } else {
                        fallbackAction(url)
                    }
                } catch {
                    fallbackAction(url)
                }
            }
        }

        let pocketReadUrlRoutingAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            // dismiss any existing modal
            self?.account.dismissAll()
            // go to home
            self?.selectedSection = .home
            // extract the slug
            guard let slug = url.pathComponents[safe: 2] else {
                Log.capture(message: "Unable to extract slug")
                fallbackAction(url)
                return
            }
            Task {
                do {
                    let itemData = try await self?.source.readerItem(by: slug)
                    if let savedItem = itemData?.0 {
                        self?.home.select(savedItem: savedItem, readableSource: source)
                    } else if let item = itemData?.1 {
                        if let recommendation = item.recommendation {
                            self?.home.select(recommendation: recommendation, readableSource: source)
                        } else {
                            self?.home.select(externalItem: item)
                        }
                    } else {
                        fallbackAction(url)
                    }
                } catch {
                    fallbackAction(url)
                }
            }
        }

        let brazeShowIconSwitcherAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            self?.account.dismissAll()
            self?.selectedSection = .account
            self?.account.isPresentingIconSwitcher = true
        }

        let navigationAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            self?.account.dismissAll()
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return
            }
            if components.path.contains("/home") {
                self?.selectedSection = .home
            } else if components.path.contains("/saves") {
                self?.selectedSection = .saves
            } else if components.path.contains("/settings") {
                self?.selectedSection = .account
            } else if components.path.contains("/premium/manage") {
                self?.selectedSection = .account
                self?.account.isPresentingPremiumStatus = true
            }
        }

        let listenAction: (URL, ReadableSource) -> Void = { [weak self] url, source in
            self?.account.dismissAll()
            self?.selectedSection = .home
            Task {
                do {
                    if let item = try await self?.source.fetchViewItem(from: url.absoluteString) {
                        if let savedItem = item.savedItem {
                            // if the saved item is found, open it and attempt to start listening
                            self?.home.select(savedItem: savedItem, readableSource: source, shouldOpenListenOnAppear: true)
                            // otherwise, we can still fall back to the usual actions
                        } else if let recommendation = item.recommendation {
                            self?.home.select(recommendation: recommendation, readableSource: source)
                        } else {
                            self?.home.select(externalItem: item)
                        }
                    } else {
                        fallbackAction(url)
                    }
                } catch {
                    fallbackAction(url)
                }
            }
        }

        let widgetRoute = WidgetRoute(action: routingAction)
        let collectionRoute = CollectionRoute(action: routingAction)
        let syndicatedRoute = SyndicationRoute(action: routingAction)
        let spotlightRoute = SpotlightRoute(action: routingAction)
        let genericItemRoute = GenericItemRoute(action: routingAction)
        let shortUrlRoute = ShortUrlRoute(action: shortUrlRoutingAction)
        let pocketShareRoute = PocketShareRoute(action: pocketShareUrlRoutingAction)
        let pocketReadRoute = PocketReadRoute(action: pocketReadUrlRoutingAction)
        let brazeIconSwitcherRoute = BrazeIconSwitcherRoute(action: brazeShowIconSwitcherAction)
        let homeRoute = HomeRoute(action: navigationAction)
        let savesRoute = SavesRoute(action: navigationAction)
        let settingsRoute = SettingsRoute(action: navigationAction)
        let managePremiumRoute = ManagePremiumRoute(action: navigationAction)
        let listenRoute = ListenRoute(action: listenAction)
        // NOTE: order matters, because there might be overlapping patterns
        // we can probably optimize by having exclusive-patterns only routes, and handle additional logic within
        // the route itself
        linkRouter.addRoutes(
            [
                // specialized routes
                widgetRoute,
                spotlightRoute,
                // getpocket.com/[path] routes
                collectionRoute,
                syndicatedRoute,
                pocketReadRoute,
                listenRoute,
                homeRoute,
                savesRoute,
                settingsRoute,
                managePremiumRoute,
                genericItemRoute,
                // pocket.co/[path] routes
                pocketShareRoute,
                brazeIconSwitcherRoute,
                shortUrlRoute
            ]
        )
    }
}
