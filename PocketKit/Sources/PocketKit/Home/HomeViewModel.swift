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

enum SeeAll {
    case saves
    case slate(SlateDetailViewModel)
    case sharedWithYou(SharedWithYouListViewModel)

    func clearRecommendationToReport() {
        switch self {
        case .saves, .sharedWithYou:
            break
        case .slate(let viewModel):
            viewModel.clearRecommendationToReport()
        }
    }

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

    @Published var selectedRecommendationToReport: Recommendation?

    @Published var tappedSeeAll: SeeAll?

    var numberOfHeroItems: Int = 1 {
        didSet {
            self.snapshot = buildSnapshot()
        }
    }

    private var adSequences: [PocketAdsSequence] = [] {
        didSet {
            guard !oldValue.isEmpty else {
                return
            }
            snapshot = buildSnapshot()
        }
    }

    private let source: Source
    let tracker: Tracker
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
    private let adStore = PocketAdsStore()

    private let recentSavesController: NSFetchedResultsController<SavedItem>
    private let recomendationsController: RichFetchedResultsController<Recommendation>
    private let sharedWithYouController: RichFetchedResultsController<SharedWithYouItem>
    private(set) var numberOfSharedWithYouItems = 0

    init(
        source: Source,
        tracker: Tracker,
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
        fetch()
    }

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status != .satisfied
    }

    /// Fetch the latest data from core data and get the NSFetechedResults Controllers subscribing to updates
    func fetch() {
        do {
            try recentSavesController.performFetch()
            try recomendationsController.performFetch()
            try sharedWithYouController.performFetch()
        } catch {
            Log.capture(error: error)
        }
    }

    /// Refresh of data triggered
    /// - Parameters:
    ///   - isForced: Whether or not the user forced the refresh
    ///   - completion: Completion block to call
    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        fetch()

        guard !isOffline else {
            completion()
            return
        }

        homeRefreshCoordinator.refresh(isForced: isForced) {
            completion()
        }
        Task {
            adSequences = await adStore.getAds()
        }
    }
}

// MARK: - Snapshot building
extension HomeViewModel {
    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let recentSaves = self.recentSavesController.fetchedObjects
        if let recentSaves, !recentSaves.isEmpty {
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
        if let sharedWithYouItems = sharedWithYouController.fetchedObjects as? [SharedWithYouItem], !sharedWithYouItems.isEmpty {
            numberOfSharedWithYouItems = sharedWithYouItems.count
            snapshot.appendSections([.sharedWithYou])
            snapshot.appendItems(sharedWithYouItems.prefix(4).map { .sharedWithYou($0.objectID) }, toSection: .sharedWithYou)
        }

        guard let slateSections = self.recomendationsController.sections, !slateSections.isEmpty else {
            snapshot.appendSections([.loading])
            snapshot.appendItems([.loading], toSection: .loading)
            return snapshot
        }

        for slateSection in slateSections {
            guard var recommendations = slateSection.objects as? [Recommendation],
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

            if numberOfHeroItems == 2 {
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
            var items = recommendations.prefix(4).map { Cell.recommendationCarousel($0.objectID) }
            // TODO: ADS - insert ads in the carousel here
            snapshot.appendItems(
                items,
                toSection: .slateCarousel(slateId)
            )
        }
        return snapshot
    }
}

// MARK: - Cell Selection
extension HomeViewModel {
    func select(cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .offline:
            return
        case .recentSaves(let objectID):
            guard let savedItem = source.viewObject(id: objectID) as? SavedItem else {
                return
            }

            select(savedItem: savedItem, at: indexPath)
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
                return
            }

            select(recommendation: recommendation, at: indexPath)
        case .sharedWithYou(let objectID):
            guard let sharedWithYouItem = source.viewObject(id: objectID) as? SharedWithYouItem else {
                return
            }
            select(sharedWithYouItem: sharedWithYouItem, at: indexPath)
        case .ad(let ID):
            // TODO: ADS - add logic for tapping on an ad here
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
            notificationCenter: notificationCenter
        ))
    }

    private func select(sharedWithYouList: [SharedWithYouItem]) {
        tappedSeeAll = .sharedWithYou(SharedWithYouListViewModel(
            list: sharedWithYouList,
            source: source,
            tracker: tracker,
            user: user,
            store: store,
            userDefaults: userDefaults,
            networkPathMonitor: networkPathMonitor,
            featureFlags: featureFlags,
            notificationCenter: notificationCenter
        ))
    }

    func select(externalItem: Item) {
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
                readableSource: .external
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: externalItem,
                source: source,
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

    func select(recommendation: Recommendation, at indexPath: IndexPath? = nil, readableSource: ReadableSource = .app) {
        var destination: ContentOpen.Destination = .internal
        let item = recommendation.item

        if let slug = recommendation.collection?.slug ?? recommendation.item.collectionSlug, featureFlags.isAssigned(flag: .nativeCollections) {
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
                readableSource: readableSource
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: recommendation.item,
                source: source,
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
            slateIndex: indexPath?.section,
            slate: slate,
            slateLineup: slateLineup,
            destination: destination,
            recommendationId: recommendation.analyticsID,
            source: readableSource
        )
    }

    private func trackSlateArticleOpen(
        url: String,
        positionInList: Int?,
        slateIndex: Int?,
        slate: Slate,
        slateLineup: SlateLineup,
        destination: ContentOpen.Destination,
        recommendationId: String,
        source: ReadableSource
    ) {
        switch source {
        case .app:
            tracker.track(event: Events.Home.SlateArticleContentOpen(
                url: url,
                positionInList: positionInList,
                slateId: slate.remoteID,
                slateRequestId: slate.requestID,
                slateExperimentId: slate.experimentID,
                slateIndex: slateIndex,
                slateLineupId: slateLineup.remoteID,
                slateLineupRequestId: slateLineup.requestID,
                slateLineupExperimentId: slateLineup.experimentID,
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

    func select(savedItem: SavedItem, at indexPath: IndexPath? = nil, readableSource: ReadableSource = .app) {
        if let slug = savedItem.item?.collection?.slug ?? savedItem.item?.collectionSlug, featureFlags.isAssigned(flag: .nativeCollections) {
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
                readableSource: readableSource
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
                featureFlagService: featureFlags
            )

            if let item = savedItem.item, item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
                selectedReadableType = .webViewSavedItem(viewModel)
            } else {
                selectedReadableType = .savedItem(viewModel)
            }
        }
        trackRecentSavesOpen(url: savedItem.url, positionInList: indexPath?.item, source: readableSource)
    }

    func select(sharedWithYouItem: SharedWithYouItem, at indexPath: IndexPath, readableSource: ReadableSource = .app) {
        var destination: ContentOpen.Destination = .internal
        if let slug = sharedWithYouItem.item.collectionSlug, featureFlags.isAssigned(flag: .nativeCollections) {
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
                readableSource: readableSource
            ))
        } else {
            let viewModel = RecommendableItemViewModel(
                item: sharedWithYouItem.item,
                source: source,
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
                guard let list = self?.sharedWithYouController.fetchedObjects as? [SharedWithYouItem] else {
                    return
                }
                self?.select(sharedWithYouList: list)
            }
        case .loading, .slateCarousel, .offline:
            return nil
        }
    }
}

// MARK: - Loading Section
extension HomeViewModel {
    static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
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
        guard let savedItem = source.viewObject(id: objectID) as? SavedItem else {
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

    private func confirmDelete(item: SavedItem, indexPath: IndexPath) {
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

    private func delete(item: SavedItem, indexPath: IndexPath) {
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
        guard let objectID = objectID, let recommendation = source.viewObject(id: objectID) as? Recommendation else {
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
        guard let sharedWithYouItem = source.viewObject(id: objectID) as? SharedWithYouItem else {
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

    private func overflowActions(for recommendation: Recommendation, at indexPath: IndexPath?) -> [ItemAction] {
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

    private func primaryAction(for recommendation: Recommendation, at indexPath: IndexPath?) -> ItemAction? {
        guard let indexPath = indexPath else {
            return nil
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

    private func primaryAction(for sharedWithYouItem: SharedWithYouItem, at indexPath: IndexPath) -> ItemAction? {
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

    private func report(_ recommendation: Recommendation, at indexPath: IndexPath) {
        selectedRecommendationToReport = recommendation
    }

    private func share(_ recommendation: Recommendation, at indexPath: IndexPath, with sender: Any?) async {
        // This view model is used within the context of a view that is presented within Saves
        let shareableUrl = await shareableUrl(recommendation.item) ?? recommendation.item.bestURL
        self.sharedActivity = PocketItemActivity.fromHome(url: shareableUrl, sender: sender)
        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Shared recommendation without slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.Home.SlateArticleShare(url: shareableUrl, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
    }

    private func share(_ savedItem: SavedItem, at indexPath: IndexPath, with sender: Any?) async {
        // This view model is used within the context of a view that is presented within Home, but
        // within the context of "Recent Saves"
        let shareableUrl = await shareableUrl(savedItem.item) ?? savedItem.url
        self.sharedActivity = PocketItemActivity.fromSaves(url: shareableUrl, sender: sender)
        tracker.track(event: Events.Home.RecentSavesCardShare(url: shareableUrl, positionInList: indexPath.item))
    }

    private func share(_ sharedWithYouItem: SharedWithYouItem, at indexPath: IndexPath, with sender: Any?) async {
        let shareableUrl = await shareableUrl(sharedWithYouItem.item) ?? sharedWithYouItem.url
        self.sharedActivity = PocketItemActivity.fromHome(url: shareableUrl, sender: sender)
        tracker.track(event: Events.Home.sharedWithYouItemShare(url: shareableUrl, positionInList: indexPath.item))
    }

    private func shareableUrl(_ item: Item?) async -> String? {
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

    private func save(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.save(recommendation: recommendation)
        let item = recommendation.item
        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Saved recommendation slate and slatelineup, not logging analytics")
            return
        }

        let givenURL = item.givenURL
        tracker.track(event: Events.Home.SlateArticleSave(url: givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
    }

    private func archive(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.archive(recommendation: recommendation)
        let item = recommendation.item
        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Archived recommendation without slate and slatelineup, not logging analytics")
            return
        }

        let givenURL = item.givenURL
        tracker.track(event: Events.Home.SlateArticleArchive(url: givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
    }

    private func archive(_ savedItem: SavedItem, at indexPath: IndexPath) {
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
            guard let sharedWithYouItem = source.viewObject(id: objectID) as? SharedWithYouItem else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could retrieve Shared With You Item from objectID: \(String(describing: objectID))")
                Log.capture(message: "Shared With You Item is null on willDisplay Home Recent Saves")
                return
            }
            tracker.track(event: Events.Home.sharedWithYouCardImpression(url: sharedWithYouItem.url, positionInList: indexPath.item))
        case .recentSaves(let objectID):
            guard let savedItem = source.viewObject(id: objectID) as? SavedItem else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could not turn recent save into Saved Item from objectID: \(String(describing: objectID))")
                Log.capture(message: "SavedItem is null on willDisplay Home Recent Saves")
                return
            }
            tracker.track(event: Events.Home.RecentSavesCardImpression(url: savedItem.url, positionInList: indexPath.item))
            return
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
                Log.breadcrumb(category: "home", level: .debug, message: "Could not turn recomendation into Recommendation from objectID: \(String(describing: objectID))")
                Log.capture(message: "Recommendation is null on willDisplay Home Recommendation")
                return
            }
            let item = recommendation.item
            guard
                let slate = recommendation.slate,
                let slateLineup = slate.slateLineup
            else {
                Log.breadcrumb(category: "home", level: .debug, message: "Tried to display recommendation without slate and slatelineup, not logging analytics")
                return
            }

            let givenURL = item.givenURL
            tracker.track(event: Events.Home.SlateArticleImpression(url: givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
        case .ad(let ID):
            // TODO: ADS - add logic for tracking add tapped here
            return
        }
    }
}

extension HomeViewModel {
    enum Section: Hashable {
        case loading
        case recentSaves
        case slateHero(NSManagedObjectID)
        case slateCarousel(NSManagedObjectID)
        case sharedWithYou
        case offline
    }

    enum Cell: Hashable {
        case loading
        case recentSaves(NSManagedObjectID)
        case recommendationHero(NSManagedObjectID)
        case recommendationCarousel(NSManagedObjectID)
        case sharedWithYou(NSManagedObjectID)
        case ad(String)
        case offline
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
            let reloadedItemIdentifiers: [Cell] = snapshot.reloadedItemIdentifiers.compactMap({ .recentSaves($0 as! NSManagedObjectID) })
            let reconfiguredItemdIdentifiers: [Cell] = snapshot.reconfiguredItemIdentifiers.compactMap({ .recentSaves($0 as! NSManagedObjectID) })
            newSnapshot.reloadItems(reloadedItemIdentifiers)
            newSnapshot.reconfigureItems(reconfiguredItemdIdentifiers)
            updateRecentSavesWidget()
        }

        if isOffline {
            // If we are offline don't try and do anything with Slates, and let the snapshot show the offline
            setRecommendationsWidgetOffline()
            self.snapshot = newSnapshot
            return
        }

        if controller == recomendationsController {
            let existingItemIdentifiers = newSnapshot.itemIdentifiers

            // Gather all variations a recomendation could exist in for reloaded identifiers
            var reloadedItemIdentifiers: [Cell] = snapshot.reloadedItemIdentifiers.compactMap({ .recommendationHero($0 as! NSManagedObjectID) })
            reloadedItemIdentifiers.append(contentsOf: snapshot.reloadedItemIdentifiers.compactMap({ .recommendationCarousel($0 as! NSManagedObjectID) }))
            // Filter to just the ones that exist in our snapshot
            reloadedItemIdentifiers = reloadedItemIdentifiers.filter({ existingItemIdentifiers.contains($0) })
            // Tell the new snapshot to reload just the ones that exist
            newSnapshot.reloadItems(reloadedItemIdentifiers)

            // Gather all variations a recomendation could exist in for reconfigured identifiers
            var reconfiguredItemIdentifiers: [Cell] = snapshot.reconfiguredItemIdentifiers.compactMap({ .recommendationHero($0 as! NSManagedObjectID) })
            reconfiguredItemIdentifiers.append(contentsOf: snapshot.reconfiguredItemIdentifiers.compactMap({ .recommendationCarousel($0 as! NSManagedObjectID) }))
            // Filter to just the ones that exist in our snapshot
            reconfiguredItemIdentifiers = reconfiguredItemIdentifiers.filter({ existingItemIdentifiers.contains($0) })
            // Tell the new snapshot to reconfigure just the ones that exist
            newSnapshot.reconfigureItems(reconfiguredItemIdentifiers)
            updateRecommendationsWidget()
        }

        if controller == sharedWithYouController {
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
        }

        self.snapshot = newSnapshot
    }
}

// MARK: recent saves widget
private extension HomeViewModel {
    func updateRecentSavesWidget() {
        guard let items = recentSavesController.fetchedObjects else {
            recentSavesWidgetUpdateService.update([])
            return
        }
        // because we might still end up with more items, slice the first n elements anyway.
        recentSavesWidgetUpdateService.update(Array(items.prefix(SyncConstants.Home.recentSaves)))
    }
}

// MARK: Recommendations - Editor's Picks widget
private extension HomeViewModel {
    func updateRecommendationsWidget() {
        guard let sections = recomendationsController.sections, !sections.isEmpty else {
            setRecommendationsWidgetOffline()
            return
        }

        let topics = sections.reduce(into: [String: [Recommendation]]()) {
            if let recommendations = $1.objects as? [Recommendation], let name = recommendations.first?.slate?.name {
                $0[name] = recommendations
            }
        }
        recommendationsWidgetUpdateService.update(topics)
    }

    func setRecommendationsWidgetOffline() {
        recommendationsWidgetUpdateService.update([:])
    }
}
