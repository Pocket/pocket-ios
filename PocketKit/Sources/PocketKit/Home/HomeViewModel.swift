// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import UIKit
import CoreData
import Analytics
import Localization
import SharedPocketKit
import SharedWithYou

enum ReadableType {
    case recommendable(RecommendableItemViewModel)
    case savedItem(SavedItemViewModel)
    case webViewRecommendable(RecommendableItemViewModel)
    case webViewSavedItem(SavedItemViewModel)
    case collection(CollectionViewModel)

    @MainActor
    func clearIsPresentingReaderSettings() {
        switch self {
        case .recommendable(let recommendationViewModel):
            recommendationViewModel.clearIsPresentingReaderSettings()
        case .savedItem(let savedItemViewModel):
            savedItemViewModel.clearIsPresentingReaderSettings()
        case .webViewRecommendable(let recommendationViewModel):
            recommendationViewModel.clearPresentedWebReaderURL()
        case .webViewSavedItem(let savedItemViewModel):
            savedItemViewModel.clearPresentedWebReaderURL()
        case .collection:
            // TODO: NATIVECOLLECTIONS - we might need to do some additional cleanup here
            break
        }
    }
}

enum ReadableSource {
    case app
    case widget
    case spotlight
    case external
}

enum RefreshState {
    case loading
    case ready
}

enum SeeAll {
    case saves
    case slate(SlateDetailViewModel)
    case sharedWithYou(SharedWithYouListViewModel)
    @MainActor
    func clearRecommendationToReport() {
        switch self {
        case .saves, .sharedWithYou:
            break
        case .slate(let viewModel):
            viewModel.clearRecommendationToReport()
        }
    }
    @MainActor
    func clearPresentedWebReaderURL() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearPresentedWebReaderURL()
        case .sharedWithYou(let viewModel):
            viewModel.clearPresentedWebReaderURL()
        }
    }
    @MainActor
    func clearSharedActivity() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearSharedActivity()
        case .sharedWithYou(let viewModel):
            viewModel.clearSharedActivity()
        }
    }
    @MainActor
    func clearIsPresentingReaderSettings() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearIsPresentingReaderSettings()
        case .sharedWithYou(let viewModel):
            viewModel.clearIsPresentingReaderSettings()
        }
    }
    @MainActor
    func clearSelectedItem() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearSelectedItem()
        case .sharedWithYou(let viewModel):
            viewModel.clearSelectedItem()
        }
    }
}

@MainActor
class HomeViewModel: NSObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias ItemIdentifier = NSManagedObjectID

    @Published var snapshot: Snapshot

    @Published var sharedActivity: PocketActivity?

    @Published var presentedAlert: PocketAlert?

    @Published var selectedReadableType: ReadableType?

    @Published var selectedRecommendationToReport: CDRecommendation?

    @Published var tappedSeeAll: SeeAll?

    private var useWideLayout: Bool = false

    private let source: Source
    let tracker: Tracker
    private let appSession: AppSession
    private let accessService: PocketAccessService
    private let user: User
    private let userDefaults: UserDefaults
    private let networkPathMonitor: NetworkPathMonitor
    private let homeRefreshCoordinator: RefreshCoordinator
    private let notificationCenter: NotificationCenter
    private var subscriptions: [AnyCancellable] = []
    private var recentSavesCount: Int = 0
    private let featureFlags: FeatureFlagServiceProtocol
    private let store: SubscriptionStore
    private let recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService
    private let recommendationsWidgetUpdateService: RecommendationsWidgetUpdateService

    private let recentSavesController: NSFetchedResultsController<CDSavedItem>
    private let recomendationsController: RichFetchedResultsController<CDRecommendation>
    private let sharedWithYouController: RichFetchedResultsController<CDSharedWithYouItem>
    private(set) var numberOfSharedWithYouItems = 0

    private var refreshState: RefreshState = .ready

    init(
        source: Source,
        tracker: Tracker,
        appsession: AppSession,
        accessService: PocketAccessService,
        networkPathMonitor: NetworkPathMonitor,
        homeRefreshCoordinator: RefreshCoordinator,
        user: User,
        store: SubscriptionStore,
        recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService,
        recommendationsWidgetUpdateService: RecommendationsWidgetUpdateService,
        userDefaults: UserDefaults,
        notificationCenter: NotificationCenter,
        featureFlags: FeatureFlagServiceProtocol
    ) {
        self.source = source
        self.tracker = tracker
        self.appSession = appsession
        self.accessService = accessService
        self.networkPathMonitor = networkPathMonitor
        networkPathMonitor.start(queue: .global(qos: .utility))
        self.homeRefreshCoordinator = homeRefreshCoordinator
        self.user = user
        self.store = store
        self.recentSavesWidgetUpdateService = recentSavesWidgetUpdateService
        self.recommendationsWidgetUpdateService = recommendationsWidgetUpdateService
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.featureFlags = featureFlags

        self.snapshot = {
            return Self.loadingSnapshot()
        }()

        self.recentSavesController = source.makeRecentSavesController()
        self.recomendationsController = source.makeHomeController()
        self.sharedWithYouController = source.makeSharedWithYouController()

        super.init()
        self.recentSavesController.delegate = self
        self.recomendationsController.delegate = self
        self.sharedWithYouController.delegate = self

        networkPathMonitor.updateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.refresh(isForced: false) { }
            }
        }
    }

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status != .satisfied
    }

    /// Fetch the latest data from core data and get the NSFetechedResults Controllers subscribing to updates
    func fetch() {
        // NOTE: despite HomeViewModel runs on MainActor, this call ends up on a different thread
        // when the app is backgrounded, thus we force it back to the main queue to avoid crashes
        // since these fetched result controller are created on viewContext
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            do {
                try recentSavesController.performFetch()
                try recomendationsController.performFetch()
                try sharedWithYouController.performFetch()
            } catch {
                Log.capture(error: error)
            }
        }
    }

    /// Refresh of data triggered
    /// - Parameters:
    ///   - isForced: Whether or not the user forced the refresh
    ///   - completion: Completion block to call
    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        guard case .ready = refreshState else {
            return
        }
        refreshState = .loading
        fetch()

        guard !isOffline else {
            completion()
            refreshState = .ready
            return
        }

        homeRefreshCoordinator.refresh(isForced: isForced) { [weak self] in
            completion()
            self?.refreshState = .ready
        }
    }
}

// MARK: - Snapshot building
extension HomeViewModel {
    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let recentSaves = self.recentSavesController.fetchedObjects
        if let recentSaves, !recentSaves.isEmpty, accessService.accessLevel != .anonymous {
            recentSavesCount = recentSaves.count
            snapshot.appendSections([.recentSaves])
            snapshot.appendItems(
                recentSaves.map { .recentSaves($0.objectID) },
                toSection: .recentSaves
            )
        }

        guard !isOffline else {
            snapshot.appendSections([.offline])
            snapshot.appendItems([.offline], toSection: .offline)
            return snapshot
        }
        // Add Shared With You section right below recent saves
        if let session = appSession.currentSession,
           !session.isAnonymous,
           let sharedWithYouItems = sharedWithYouController.fetchedObjects as? [CDSharedWithYouItem], !sharedWithYouItems.isEmpty {
            numberOfSharedWithYouItems = sharedWithYouItems.count
            snapshot.appendSections([.sharedWithYou])
            snapshot.appendItems(sharedWithYouItems.prefix(4).map { .sharedWithYou($0.objectID) }, toSection: .sharedWithYou)
        }

        guard let slateSections = self.recomendationsController.sections, !slateSections.isEmpty else {
            snapshot.appendSections([.loading])
            snapshot.appendItems([.loading], toSection: .loading)
            return snapshot
        }

        if accessService.accessLevel == .anonymous {
            snapshot.appendSections([.signinBanner])
            snapshot.appendItems([.singinBanner], toSection: .signinBanner)
        }

        for slateSection in slateSections {
            guard var recommendations = slateSection.objects as? [CDRecommendation],
                  !recommendations.isEmpty,
                  let slateId = recommendations.first?.slate?.objectID
            else {
                continue
            }

            let hero = recommendations.removeFirst()
            snapshot.appendSections([.slateHero(slateId)])
            snapshot.appendItems(
                [.recommendationHero(hero.objectID)],
                toSection: .slateHero(slateId)
            )
            // Check if recommendations is empty. It shouldn't, but there
            // is still a theoretic scenario where we removed an element
            // as the first hero, and the list becomes empty.
            if useWideLayout, !recommendations.isEmpty {
                let hero2 = recommendations.removeFirst()
                snapshot.appendItems(
                    [.recommendationHero(hero2.objectID)],
                    toSection: .slateHero(slateId)
                )
            }

            guard !recommendations.isEmpty else {
                continue
            }

            snapshot.appendSections([.slateCarousel(slateId)])
            snapshot.appendItems(
                recommendations.prefix(4).map { .recommendationCarousel($0.objectID) },
                toSection: .slateCarousel(slateId)
            )
        }
        return snapshot
    }

    /// Updates the collection view layout for compact or wide layout, if this changed.
    /// Wide layout has two columns and two hero items per recommendation section.
    /// - Parameter heroItems: the number of hero items to use.
    func updateLayout(_ shouldUseWideLayout: Bool) {
        guard shouldUseWideLayout != useWideLayout else {
            return
        }
        useWideLayout = shouldUseWideLayout
        snapshot = buildSnapshot()
    }
}

// MARK: - Cell Selection
extension HomeViewModel {
    func select(cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .offline:
            return
        case .recentSaves(let objectID):
            guard let savedItem = source.viewObject(id: objectID) as? CDSavedItem else {
                return
            }
            select(savedItem: savedItem, at: indexPath)
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.viewObject(id: objectID) as? CDRecommendation else {
                return
            }
            if let savedItem = recommendation.item.savedItem {
                select(savedItem: savedItem, at: indexPath)
            } else {
                select(recommendation: recommendation, at: indexPath)
            }
        case .sharedWithYou(let objectID):
            guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
                return
            }
            select(sharedWithYouItem: sharedWithYouItem, at: indexPath)
        case .singinBanner:
            return
        }
    }

    private func select(slate: Slate) {
        tappedSeeAll = .slate(SlateDetailViewModel(
            slate: slate,
            source: source,
            tracker: tracker.childTracker(hosting: .slateDetail.screen),
            user: user,
            store: store,
            userDefaults: userDefaults,
            networkPathMonitor: networkPathMonitor,
            featureFlags: featureFlags,
            notificationCenter: notificationCenter,
            accessService: accessService
        ))
    }

    private func select(sharedWithYouList: [CDSharedWithYouItem]) {
        tappedSeeAll = .sharedWithYou(SharedWithYouListViewModel(
            list: sharedWithYouList,
            source: source,
            tracker: tracker,
            user: user,
            store: store,
            userDefaults: userDefaults,
            networkPathMonitor: networkPathMonitor,
            featureFlags: featureFlags,
            notificationCenter: notificationCenter,
            accessService: accessService
        ))
    }

    func select(externalItem: CDItem) {
        var destination: ContentOpen.Destination = .internal
        if let slug = externalItem.collection?.slug ?? externalItem.collectionSlug {
            selectedReadableType = .collection(CollectionViewModel(
                slug: slug,
                source: source,
                tracker: tracker,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                featureFlags: featureFlags,
                notificationCenter: notificationCenter,
                readableSource: .external,
                accessService: accessService
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: externalItem,
                source: source,
                accessService: accessService,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults,
                readableSource: .external
            )

            if externalItem.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
                selectedReadableType = .webViewRecommendable(viewModel)
                destination = .external
            } else {
                selectedReadableType = .recommendable(viewModel)
            }
        }
        tracker.track(event: Events.Deeplinks.deeplinkArticleContentOpen(url: externalItem.givenURL, destination: destination))
    }

    func select(recommendation: CDRecommendation, at indexPath: IndexPath? = nil, readableSource: ReadableSource = .app) {
        var destination: ContentOpen.Destination = .internal
        let item = recommendation.item

        if let slug = recommendation.collection?.slug ?? recommendation.item.collectionSlug {
            selectedReadableType = .collection(CollectionViewModel(
                slug: slug,
                source: source,
                tracker: tracker,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                featureFlags: featureFlags,
                notificationCenter: notificationCenter,
                readableSource: readableSource,
                accessService: accessService
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: recommendation.item,
                source: source,
                accessService: accessService,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults,
                readableSource: readableSource
            )

            if item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
                selectedReadableType = .webViewRecommendable(viewModel)
                destination = .external
            } else {
                selectedReadableType = .recommendable(viewModel)
            }
        }

        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Selected recommendation without an associated slate and slatelineup, not logging analytics")
            return
        }

        let givenURL = item.givenURL
        trackSlateArticleOpen(
            url: givenURL,
            positionInList: indexPath?.item,
            destination: destination,
            recommendationId: recommendation.analyticsID,
            source: readableSource
        )
    }

    private func trackSlateArticleOpen(
        url: String,
        positionInList: Int?,
        destination: ContentOpen.Destination,
        recommendationId: String,
        source: ReadableSource
    ) {
        switch source {
        case .app:
            tracker.track(event: Events.Home.SlateArticleContentOpen(
                url: url,
                positionInList: positionInList,
                recommendationId: recommendationId,
                destination: destination
            ))
        case .external:
            tracker.track(event: Events.Deeplinks.deeplinkArticleContentOpen(url: url, destination: destination))
        case .widget:
            tracker.track(event: Events.Widgets.slateArticleContentOpen(
                url: url,
                recommendationId: recommendationId,
                destination: destination
            ))
        case .spotlight:
            // Spot light never indexes recs.
            Log.breadcrumb(category: "spotlight", level: .warning, message: "Somehow entered slate open from Spotlight, which should not happen")
        }
    }

    func select(savedItem: CDSavedItem, at indexPath: IndexPath? = nil, readableSource: ReadableSource = .app, shouldOpenListenOnAppear: Bool = false) {
        if let slug = savedItem.item?.collection?.slug ?? savedItem.item?.collectionSlug {
            selectedReadableType = .collection(CollectionViewModel(
                slug: slug,
                source: source,
                tracker: tracker,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                featureFlags: featureFlags,
                notificationCenter: notificationCenter,
                readableSource: readableSource,
                accessService: accessService
            ))
        } else {
            let viewModel = SavedItemViewModel(
                item: savedItem,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                notificationCenter: notificationCenter,
                readableSource: readableSource,
                featureFlagService: featureFlags,
                shouldOpenListenOnAppear: shouldOpenListenOnAppear
            )

            if let item = savedItem.item, item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
                selectedReadableType = .webViewSavedItem(viewModel)
            } else {
                selectedReadableType = .savedItem(viewModel)
            }
        }
        trackRecentSavesOpen(url: savedItem.url, positionInList: indexPath?.item, source: readableSource)
    }

    func select(sharedWithYouItem: CDSharedWithYouItem, at indexPath: IndexPath, readableSource: ReadableSource = .app) {
        var destination: ContentOpen.Destination = .internal
        if let slug = sharedWithYouItem.item.collectionSlug {
            selectedReadableType = .collection(CollectionViewModel(
                slug: slug,
                source: source,
                tracker: tracker,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                featureFlags: featureFlags,
                notificationCenter: notificationCenter,
                readableSource: readableSource,
                accessService: accessService
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: sharedWithYouItem.item,
                source: source,
                accessService: accessService,
                tracker: tracker,
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults,
                readableSource: readableSource
            )
            if sharedWithYouItem.item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
                selectedReadableType = .webViewRecommendable(viewModel)
                destination = .external
            } else {
                selectedReadableType = .recommendable(viewModel)
            }
        }
        tracker.track(event: Events.Home.sharedWithYouContentOpen(url: sharedWithYouItem.url, positionInList: indexPath.item, destination: destination))
    }

    private func trackRecentSavesOpen(url: String, positionInList: Int?, source: ReadableSource) {
        switch source {
        case .app:
            tracker.track(event: Events.Home.RecentSavesCardContentOpen(url: url, positionInList: positionInList))
        case .external:
            tracker.track(event: Events.Deeplinks.deeplinkArticleContentOpen(url: url, destination: .internal))
        case .widget:
            tracker.track(event: Events.Widgets.recentSavesCardContentOpen(url: url))
        case .spotlight:
            tracker.track(event: Events.Spotlight.spotlightSearchContentOpen(url: url))
        }
    }
}

// MARK: - Section Headers
extension HomeViewModel {
    func sectionHeaderViewModel(for section: Section) -> SectionHeaderView.Model? {
        switch section {
        case .recentSaves:
            return .init(
                name: Localization.recentSaves,
                buttonTitle: Localization.seeAll,
                buttonImage: UIImage(asset: .chevronRight)
            ) { [weak self] in
                self?.tappedSeeAll = .saves
            }
        case .slateHero(let objectID):
            guard let slate = source.viewObject(id: objectID) as? Slate else {
                return nil
            }

            return .init(
                name: slate.name ?? "",
                buttonTitle: Localization.seeAll,
                buttonImage: UIImage(asset: .chevronRight)
            ) { [weak self] in
                self?.select(slate: slate)
            }
        case .sharedWithYou:
            return .init(
                name: SWHighlightCenter.highlightCollectionTitle,
                buttonTitle: Localization.seeAll,
                buttonImage: UIImage(asset: .chevronRight)
            ) { [weak self] in
                guard let list = self?.sharedWithYouController.fetchedObjects as? [CDSharedWithYouItem] else {
                    return
                }
                self?.select(sharedWithYouList: list)
            }
        case .loading, .slateCarousel, .offline, .signinBanner:
            return nil
        }
    }
}

// MARK: - Loading Section
extension HomeViewModel {
    private static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        Log.breadcrumb(category: "home", level: .debug, message: "➡️ Sending loading snapshot.")
        return snapshot
    }
}

// MARK: - Signed out home
extension HomeViewModel {
    func requestAuthentication(_ analyticsSource: Events.SignedOut.LoginSource) {
        self.accessService.requestAuthentication(analyticsSource)
    }
}

// MARK: - Recent Saves Model & Actions
extension HomeViewModel {
    func numberOfRecentSavesItem() -> Int {
        return recentSavesCount
    }

    func recentSavesCellConfiguration(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath
    ) -> RecentSavesCellConfiguration? {
        guard let savedItem = source.viewObject(id: objectID) as? CDSavedItem else {
            return nil
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in
                self?.source.unfavorite(item: savedItem)
            }
        } else {
            favoriteAction = .favorite { [weak self] _ in
                self?.source.favorite(item: savedItem)
            }
        }

        return RecentSavesCellConfiguration(
            item: savedItem,
            favoriteAction: favoriteAction,
            overflowActions: [
                .share { [weak self] sender in
                    Task {
                        await self?.share(savedItem, at: indexPath, with: sender)
                    }
                },
                .archive { [weak self] _ in
                    self?.archive(savedItem, at: indexPath)
                },
                .delete { [weak self] _ in
                    self?.confirmDelete(item: savedItem, indexPath: indexPath)
                }
            ]
        )
    }

    private func confirmDelete(item: CDSavedItem, indexPath: IndexPath) {
        presentedAlert = PocketAlert(
            title: Localization.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: Localization.yes, style: .destructive) { [weak self] _ in
                    self?.presentedAlert = nil
                    self?.delete(item: item, indexPath: indexPath)
                }
            ],
            preferredAction: nil
        )
    }

    private func delete(item: CDSavedItem, indexPath: IndexPath) {
        presentedAlert = nil
        tracker.track(event: Events.Home.RecentSavesCardDelete(url: item.url, positionInList: indexPath.item))
        source.delete(item: item)
    }
}

// MARK: - Slate Model
extension HomeViewModel {
    func slateModel(for objectID: NSManagedObjectID) -> Slate? {
        return source.viewObject(id: objectID) as? Slate
    }
}

// MARK: Recommendation View Model & Actions
extension HomeViewModel {
    func numberOfCarouselItemsForSlate(with id: NSManagedObjectID) -> Int {
        let count = (source.viewObject(id: id) as? Slate)?
            .recommendations?.count ?? 0

        return max(0, count - 1)
    }

    func recommendationHeroViewModel(
        for objectID: NSManagedObjectID? = nil,
        at indexPath: IndexPath? = nil
    ) -> HomeItemCellViewModel? {
        guard let objectID = objectID, let recommendation = source.viewObject(id: objectID) as? CDRecommendation else {
            return nil
        }

        return HomeItemCellViewModel(
            item: recommendation.item,
            overflowActions: overflowActions(for: recommendation, at: indexPath),
            primaryAction: primaryAction(for: recommendation, at: indexPath),
            imageURL: recommendation.bestImageURL,
            title: recommendation.title
        )
    }

    func recommendationCellConfiguration(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath
    ) -> RecommendationCellConfiguration? {
        recommendationHeroViewModel(for: objectID, at: indexPath)
            .flatMap(RecommendationCellConfiguration.init)
    }

    func sharedWithYouCellConfiguration(for objectID: NSManagedObjectID, at indexPath: IndexPath) -> SharedWithYouCellConfiguration? {
        guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
            return nil
        }
        let viewModel = HomeItemCellViewModel(
            item: sharedWithYouItem.item,
            overflowActions: [ .share { [weak self] sender in
                Task {
                    await self?.share(sharedWithYouItem, at: indexPath, with: sender)
                }
            }],
            primaryAction: primaryAction(for: sharedWithYouItem, at: indexPath),
            imageURL: sharedWithYouItem.item.topImageURL,
            title: sharedWithYouItem.item.title
        )
        return SharedWithYouCellConfiguration(viewModel: viewModel, sharedWithYouUrlString: sharedWithYouItem.url)
    }

    private func overflowActions(for recommendation: CDRecommendation, at indexPath: IndexPath?) -> [ItemAction] {
        guard let indexPath = indexPath else {
            return []
        }

        return [
            .share { [weak self] sender in
                Task {
                    await self?.share(recommendation, at: indexPath, with: sender)
                }
            },
            .report { [weak self] _ in
                self?.report(recommendation, at: indexPath)
            }
        ]
    }

    private func primaryAction(for recommendation: CDRecommendation, at indexPath: IndexPath?) -> ItemAction? {
        guard let indexPath = indexPath else {
            return nil
        }
        // NOTE: we don't need to listen to session changes since HomeViewModel gets re-instantiated every time
        // the app state changes (e.g. from Onboarding to signed in to anonymous, etc.
        if let session = appSession.currentSession, session.isAnonymous {
            return .recommendationPrimary { [weak self] _ in
                self?.accessService.requestAuthentication(.recommendationCard)
            }
        }

        return .recommendationPrimary { [weak self] _ in
            let isSaved = recommendation.item.savedItem != nil
            && recommendation.item.savedItem?.isArchived == false

            if isSaved {
                self?.archive(recommendation, at: indexPath)
            } else {
                self?.save(recommendation, at: indexPath)
            }
        }
    }

    private func primaryAction(for sharedWithYouItem: CDSharedWithYouItem, at indexPath: IndexPath) -> ItemAction? {
        return .sharedWithYouPrimary { [weak self] _ in
            if let savedItem = sharedWithYouItem.item.savedItem, !savedItem.isArchived {
                self?.source.archive(item: savedItem)
                self?.tracker.track(event: Events.Home.sharedWithYouItemArchive(url: sharedWithYouItem.url, positionInList: indexPath.item))
            } else {
                self?.source.save(item: sharedWithYouItem.item)
                self?.tracker.track(event: Events.Home.sharedWithYouItemSave(url: sharedWithYouItem.url, positionInList: indexPath.item))
            }
        }
    }

    private func report(_ recommendation: CDRecommendation, at indexPath: IndexPath) {
        selectedRecommendationToReport = recommendation
    }

    private func share(_ recommendation: CDRecommendation, at indexPath: IndexPath, with sender: Any?) async {
        // This view model is used within the context of a view that is presented within Saves
        let shareableUrl = await shareableUrl(recommendation.item) ?? recommendation.item.bestURL
        self.sharedActivity = PocketItemActivity.fromHome(url: shareableUrl, sender: sender)
        tracker.track(event: Events.Home.SlateArticleShare(url: shareableUrl, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
    }

    private func share(_ savedItem: CDSavedItem, at indexPath: IndexPath, with sender: Any?) async {
        // This view model is used within the context of a view that is presented within Home, but
        // within the context of "Recent Saves"
        let shareableUrl = await shareableUrl(savedItem.item) ?? savedItem.url
        self.sharedActivity = PocketItemActivity.fromSaves(url: shareableUrl, sender: sender)
        tracker.track(event: Events.Home.RecentSavesCardShare(url: shareableUrl, positionInList: indexPath.item))
    }

    private func share(_ sharedWithYouItem: CDSharedWithYouItem, at indexPath: IndexPath, with sender: Any?) async {
        let shareableUrl = await shareableUrl(sharedWithYouItem.item) ?? sharedWithYouItem.url
        self.sharedActivity = PocketItemActivity.fromHome(url: shareableUrl, sender: sender)
        tracker.track(event: Events.Home.sharedWithYouItemShare(url: shareableUrl, positionInList: indexPath.item))
    }

    private func shareableUrl(_ item: CDItem?) async -> String? {
        guard let item else {
            return nil
        }
        var shareUrl: String?
        if let existingSharetUrl = item.shareURL {
            shareUrl = existingSharetUrl
        } else {
            shareUrl = try? await source.requestShareUrl(item.givenURL)
        }
        return shareUrl
    }

    private func save(_ recommendation: CDRecommendation, at indexPath: IndexPath) {
        source.save(recommendation: recommendation)
        let givenURL = recommendation.item.givenURL
        tracker.track(event: Events.Home.SlateArticleSave(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
    }

    private func archive(_ recommendation: CDRecommendation, at indexPath: IndexPath) {
        source.archive(recommendation: recommendation)
        let givenURL = recommendation.item.givenURL
        tracker.track(event: Events.Home.SlateArticleArchive(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
    }

    private func archive(_ savedItem: CDSavedItem, at indexPath: IndexPath) {
        self.source.archive(item: savedItem)
        tracker.track(event: Events.Home.RecentSavesCardArchive(url: savedItem.url, positionInList: indexPath.item))
    }
}

// MARK: - Cell Lifecycle
extension HomeViewModel {
    func willDisplay(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .offline:
            return
        case .sharedWithYou(let objectID):
            guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could retrieve Shared With You Item from objectID: \(String(describing: objectID))")
                Log.capture(message: "Shared With You Item is null on willDisplay Home Recent Saves")
                return
            }
            tracker.track(event: Events.Home.sharedWithYouCardImpression(url: sharedWithYouItem.url, positionInList: indexPath.item))
        case .recentSaves(let objectID):
            guard let savedItem = source.viewObject(id: objectID) as? CDSavedItem else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could not turn recent save into Saved Item from objectID: \(String(describing: objectID))")
                Log.capture(message: "SavedItem is null on willDisplay Home Recent Saves")
                return
            }
            tracker.track(event: Events.Home.RecentSavesCardImpression(url: savedItem.url, positionInList: indexPath.item))
            return
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.viewObject(id: objectID) as? CDRecommendation else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could not turn recomendation into Recommendation from objectID: \(String(describing: objectID))")
                Log.capture(message: "Recommendation is null on willDisplay Home Recommendation")
                return
            }
            let item = recommendation.item
            guard recommendation.slate?.slateLineup != nil else {
                Log.breadcrumb(category: "home", level: .debug, message: "Tried to display recommendation without slate and slatelineup, not logging analytics")
                return
            }

            let givenURL = item.givenURL
            tracker.track(event: Events.Home.SlateArticleImpression(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
        case .singinBanner:
            tracker.track(event: Events.SignedOut.signinBannerImpression())
            return
        }
    }
}

extension HomeViewModel {
    enum Section: Hashable, CustomStringConvertible {
        case loading
        case recentSaves
        case slateHero(NSManagedObjectID)
        case slateCarousel(NSManagedObjectID)
        case sharedWithYou
        case offline
        case signinBanner

        var description: String {
            switch self {
            case .loading:
                return "Loading"
            case .recentSaves:
                return "Recent Saves"
            case .slateHero(let nSManagedObjectID):
                return "Slate Hero"
            case .slateCarousel(let nSManagedObjectID):
                return "Slate Carousel"
            case .sharedWithYou:
                return "Shared With You"
            case .offline:
                return "Offline"
            case .signinBanner:
                return "Sign in or sign up"
            }
        }
    }

    enum Cell: Hashable {
        case loading
        case recentSaves(NSManagedObjectID)
        case recommendationHero(NSManagedObjectID)
        case recommendationCarousel(NSManagedObjectID)
        case sharedWithYou(NSManagedObjectID)
        case offline
        case singinBanner
    }
}

extension HomeViewModel {
    func clearRecommendationToReport() {
        tappedSeeAll?.clearRecommendationToReport()
        selectedRecommendationToReport = nil
    }

    func clearPresentedWebReaderURL() {
        tappedSeeAll?.clearPresentedWebReaderURL()
    }

    func clearSharedActivity() {
        tappedSeeAll?.clearSharedActivity()
        sharedActivity = nil
    }

    func clearIsPresentingReaderSettings() {
        selectedReadableType?.clearIsPresentingReaderSettings()
        tappedSeeAll?.clearIsPresentingReaderSettings()
    }

    func clearSelectedItem() {
        tappedSeeAll?.clearSelectedItem()
        selectedReadableType = nil
    }

    func clearTappedSeeAll() {
        tappedSeeAll = nil
    }
}

extension HomeViewModel {
    func activityItemsForSelectedItem(url: URL) -> [UIActivity] {
        switch selectedReadableType {
        case .recommendable(let viewModel),
                .webViewRecommendable(let viewModel):
            return viewModel.webViewActivityItems(url: url)
        case .savedItem(let viewModel),
                .webViewSavedItem(let viewModel):
            return viewModel.webViewActivityItems(url: url)
        case .collection, .none:
            return []
        }
    }
}

extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = buildSnapshot()

        if controller == recentSavesController {
            if accessService.accessLevel == .anonymous {
                clearRecentSavesWidget()
            } else {
                let reloadedItems: [Cell] = snapshot.reloadedItemIdentifiers.compactMap({ .recentSaves($0 as! NSManagedObjectID) })
                let reconfiguredItems: [Cell] = snapshot.reconfiguredItemIdentifiers.compactMap({ .recentSaves($0 as! NSManagedObjectID) })
                newSnapshot.reloadItems(reloadedItems)
                newSnapshot.reconfigureItems(reconfiguredItems)
                updateRecentSavesWidget()
                Log.breadcrumb(category: "home", level: .debug, message: "➡️ Building recent saves section in didChangeContentWith. #reloaded items: \(reloadedItems.count), #reconfigured items: \(reconfiguredItems.count)")
            }
        }

        if isOffline {
            // If we are offline don't try and do anything with Slates, and let the snapshot show the offline
            setRecommendationsWidgetOffline()
            self.snapshot = newSnapshot
            Log.breadcrumb(category: "home", level: .debug, message: "➡️ Providing offline snapshot.")
            return
        }

        if controller == recomendationsController {
            let existingItemIdentifiers = newSnapshot.itemIdentifiers

            // Gather all variations a recomendation could exist in for reloaded identifiers
            var reloadedItems: [Cell] = snapshot.reloadedItemIdentifiers.compactMap({ .recommendationHero($0 as! NSManagedObjectID) })
            reloadedItems.append(contentsOf: snapshot.reloadedItemIdentifiers.compactMap({ .recommendationCarousel($0 as! NSManagedObjectID) }))
            // Filter to just the ones that exist in our snapshot
            reloadedItems = reloadedItems.filter({ existingItemIdentifiers.contains($0) })
            // Tell the new snapshot to reload just the ones that exist
            newSnapshot.reloadItems(reloadedItems)

            // Gather all variations a recomendation could exist in for reconfigured identifiers
            var reconfiguredItems: [Cell] = snapshot.reconfiguredItemIdentifiers.compactMap({ .recommendationHero($0 as! NSManagedObjectID) })
            reconfiguredItems.append(contentsOf: snapshot.reconfiguredItemIdentifiers.compactMap({ .recommendationCarousel($0 as! NSManagedObjectID) }))
            // Filter to just the ones that exist in our snapshot
            reconfiguredItems = reconfiguredItems.filter({ existingItemIdentifiers.contains($0) })
            // Tell the new snapshot to reconfigure just the ones that exist
            newSnapshot.reconfigureItems(reconfiguredItems)
            updateRecommendationsWidget()
            Log.breadcrumb(category: "home", level: .debug, message: "➡️ Building recommendations section in didChangeContentWith. #reloaded items: \(reloadedItems.count), #reconfigured items: \(reconfiguredItems.count)")
        }

        if let session = appSession.currentSession,
            !session.isAnonymous,
            controller == sharedWithYouController {
            let existingItemIdentifiers = newSnapshot.itemIdentifiers
            let reloadedItems: [Cell] =
            snapshot
                .reloadedItemIdentifiers
                .compactMap { .sharedWithYou($0 as! NSManagedObjectID) }
                .filter { existingItemIdentifiers.contains($0) }
            let reconfiguredItems: [Cell] =
            snapshot
                .reconfiguredItemIdentifiers
                .compactMap { .sharedWithYou($0 as! NSManagedObjectID) }
                .filter { existingItemIdentifiers.contains($0) }
            newSnapshot.reloadItems(reloadedItems)
            newSnapshot.reconfigureItems(reconfiguredItems)
            Log.breadcrumb(category: "home", level: .debug, message: "➡️ Building shared with you section in didChangeContentWith. #reloaded items: \(reloadedItems.count), #reconfigured items: \(reconfiguredItems.count)")
        }

        self.snapshot = newSnapshot
    }
}

// MARK: recent saves widget
private extension HomeViewModel {
    /// Updates the recent saves widget with the latest recommendations
    func updateRecentSavesWidget() {
        guard let items = recentSavesController.fetchedObjects else {
            recentSavesWidgetUpdateService.update([])
            return
        }
        // because we might still end up with more items, slice the first n elements anyway.
        recentSavesWidgetUpdateService.update(Array(items.prefix(SyncConstants.Home.recentSaves)))
    }

    /// Clears the recent saves widget. Used for anonymous access
    func clearRecentSavesWidget() {
        recentSavesWidgetUpdateService.update([])
    }
}

// MARK: Recommendations - Editor's Picks widget
private extension HomeViewModel {
    func updateRecommendationsWidget() {
        guard let sections = recomendationsController.sections, !sections.isEmpty else {
            setRecommendationsWidgetOffline()
            return
        }

        let topics = sections.reduce(into: [String: [CDRecommendation]]()) {
            if let recommendations = $1.objects as? [CDRecommendation], let name = recommendations.first?.slate?.name {
                $0[name] = recommendations
            }
        }
        recommendationsWidgetUpdateService.update(topics)
    }

    func setRecommendationsWidgetOffline() {
        recommendationsWidgetUpdateService.update([:])
    }
}
