import Sync
import Combine
import UIKit
import CoreData
import Analytics

enum ReadableType {
    case recommendation(RecommendationViewModel)
    case savedItem(SavedItemViewModel)
    case webViewRecommendation(RecommendationViewModel)
    case webViewSavedItem(SavedItemViewModel)

    func clearIsPresentingReaderSettings() {
        switch self {
        case .recommendation(let recommendationViewModel):
            recommendationViewModel.clearIsPresentingReaderSettings()
        case .savedItem(let savedItemViewModel):
            savedItemViewModel.clearIsPresentingReaderSettings()
        case .webViewRecommendation(let recommendationViewModel):
            recommendationViewModel.clearPresentedWebReaderURL()
        case .webViewSavedItem(let savedItemViewModel):
            savedItemViewModel.clearPresentedWebReaderURL()
        }
    }
}

enum SeeAll {
    case saves
    case slate(SlateDetailViewModel)

    func clearRecommendationToReport() {
        switch self {
        case .saves:
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
        }
    }

    func clearSharedActivity() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearSharedActivity()
        }
    }

    func clearIsPresentingReaderSettings() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearIsPresentingReaderSettings()
        }
    }

    func clearSelectedItem() {
        switch self {
        case .saves:
            break
        case .slate(let viewModel):
            viewModel.clearSelectedItem()
        }
    }
}

class HomeViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias ItemIdentifier = NSManagedObjectID

    static let lineupIdentifier = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"

    @Published
    var snapshot: Snapshot

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var selectedReadableType: ReadableType?

    @Published
    var selectedRecommendationToReport: Recommendation?

    @Published
    var tappedSeeAll: SeeAll?

    private let source: Source
    private let tracker: Tracker
    private let networkPathMonitor: NetworkPathMonitor
    private let homeRefreshCoordinator: HomeRefreshCoordinatorProtocol
    private var subscriptions: [AnyCancellable] = []
    private var recentSavesCount: Int = 0

    init(
        source: Source,
        tracker: Tracker,
        networkPathMonitor: NetworkPathMonitor,
        homeRefreshCoordinator: HomeRefreshCoordinatorProtocol
    ) {
        self.source = source
        self.tracker = tracker
        self.networkPathMonitor = networkPathMonitor
        networkPathMonitor.start(queue: .global(qos: .utility))
        self.homeRefreshCoordinator = homeRefreshCoordinator

        self.snapshot = {
            return Self.loadingSnapshot()
        }()

        NotificationCenter.default.publisher(
            for: NSManagedObjectContext.didSaveObjectsNotification,
            object: nil
        ).sink { [weak self] notification in
            do {
                try self?.handle(notification: notification)
            } catch {
                Log.capture(error: error)
            }
        }.store(in: &subscriptions)

        networkPathMonitor.updateHandler = { [weak self] path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self?.refresh(isForced: true) { }
                }
            }
        }
    }

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status != .satisfied
    }

    func fetch() {
        do {
            let snapshot = try rebuildSnapshot()
            guard snapshot.numberOfSections != 0 else { return }
            self.snapshot = snapshot
        } catch {
            Log.capture(error: error)
        }
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        guard !isOffline else {
            do {
                snapshot = try rebuildSnapshot()
            } catch {
                Log.capture(error: error)
            }

            completion()
            return
        }

        homeRefreshCoordinator.refresh(isForced: isForced) {
            completion()
        }
    }
}

// MARK: - Snapshot building
extension HomeViewModel {
    private func handle(notification: Notification) throws {
        var snapshot = try rebuildSnapshot()

        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else {
            self.snapshot = snapshot
            return
        }

        var itemsToReload: [Cell] = []
        // Reload recent saves whose SaveItems have updated
        // e.g. the SavedItem was favorited
        itemsToReload += updatedObjects
            .compactMap { $0 as? SavedItem }
            .map { .recentSaves($0.objectID) }

        // Reload recommendations whose Items or SavedItems have changed
        // e.g.
        // - Item.savedItem was set to nil or a new object
        // - SavedItem was archived
        itemsToReload += (
            updatedObjects.compactMap { $0 as? Item }
            + updatedObjects.compactMap { ($0 as? SavedItem)?.item }
        )
        .compactMap(\.recommendation)
        .flatMap {[
            .recommendationHero($0.objectID),
            .recommendationCarousel($0.objectID)
        ]}

        snapshot.reloadItems(
            Set(itemsToReload)
                .filter { snapshot.indexOfItem($0) != nil }
        )
        self.snapshot = snapshot
    }

    private func rebuildSnapshot() throws -> Snapshot {
        let recentSaves = try source.recentSaves(limit: 5)
        let slateLineup = try source.slateLineup(identifier: Self.lineupIdentifier)

        var snapshot = Snapshot()

        recentSavesCount = recentSaves.count
        if !recentSaves.isEmpty {
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

        if let slateLineup = slateLineup,
           let slates = slateLineup.slates?.compactMap({ $0 as? Slate }) {
            for slate in slates {
                guard var recs = slate.recommendations?.compactMap({ $0 as? Recommendation }),
                      !recs.isEmpty else {
                    continue
                }

                let hero = recs.removeFirst()
                snapshot.appendSections([.slateHero(slate.objectID)])
                snapshot.appendItems(
                    [.recommendationHero(hero.objectID)],
                    toSection: .slateHero(slate.objectID)
                )

                guard !recs.isEmpty else {
                    continue
                }
                snapshot.appendSections([.slateCarousel(slate.objectID)])
                snapshot.appendItems(
                    recs[0...min(3, recs.endIndex - 1)].map { .recommendationCarousel($0.objectID) },
                    toSection: .slateCarousel(slate.objectID)
                )
            }
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
            guard let savedItem = source.object(id: objectID) as? SavedItem else {
                return
            }

            select(savedItem: savedItem, at: indexPath)
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.object(id: objectID) as? Recommendation else {
                return
            }

            select(recommendation: recommendation, at: indexPath)
        }
    }

    private func select(slate: Slate) {
        tappedSeeAll = .slate(SlateDetailViewModel(
            slate: slate,
            source: source,
            tracker: tracker.childTracker(hosting: .slateDetail.screen)
        ))
    }

    private func select(recommendation: Recommendation, at indexPath: IndexPath) {
        let viewModel = RecommendationViewModel(
            recommendation: recommendation,
            source: source,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            pasteboard: UIPasteboard.general
        )

        guard let item = recommendation.item else {
            Log.capture(message: "Selected recommendation without an associated item")
            return
        }

        if item.shouldOpenInWebView {
            selectedReadableType = .webViewRecommendation(viewModel)
        } else {
            selectedReadableType = .recommendation(viewModel)
        }

        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Selected recommendation without an associated slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.Home.SlateArticleContentOpen(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.remoteID))
    }

    private func select(savedItem: SavedItem, at indexPath: IndexPath) {
        let viewModel = SavedItemViewModel(
            item: savedItem,
            source: source,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            pasteboard: UIPasteboard.general
        )

        if let item = savedItem.item, item.shouldOpenInWebView {
            selectedReadableType = .webViewSavedItem(viewModel)
        } else {
            selectedReadableType = .savedItem(viewModel)
        }
        tracker.track(event: Events.Home.RecentSavesCardContentOpen(url: savedItem.url, positionInList: indexPath.item))
    }
}

// MARK: - Section Headers
extension HomeViewModel {
    func sectionHeaderViewModel(for section: Section) -> SectionHeaderView.Model? {
        switch section {
        case .recentSaves:
            return .init(
                name: L10n.recentSaves,
                buttonTitle: L10n.save,
                buttonImage: nil
            ) { [weak self] in
                self?.tappedSeeAll = .saves
            }
        case .slateHero(let objectID):
            guard let slate = source.viewObject(id: objectID) as? Slate else {
                return nil
            }

            return .init(
                name: slate.name ?? "",
                buttonTitle: L10n.seeAll,
                buttonImage: UIImage(asset: .chevronRight)
            ) { [weak self] in
                self?.select(slate: slate)
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

    func recentSavesViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath
    ) -> RecentSavesItemCell.Model? {
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

        return RecentSavesItemCell.Model(
            item: savedItem,
            favoriteAction: favoriteAction,
            overflowActions: [
                .share { [weak self] sender in
                    self?.share(savedItem, at: indexPath, with: sender)
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
            title: L10n.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: L10n.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: L10n.yes, style: .destructive) { [weak self] _ in
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
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeRecommendationCellViewModel? {
        guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
            return nil
        }

        return HomeRecommendationCellViewModel(
            recommendation: recommendation,
            overflowActions: overflowActions(for: recommendation, at: indexPath),
            primaryAction: primaryAction(for: recommendation, at: indexPath)
        )
    }

    func recommendationHeroWideViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeRecommendationCellHeroWideViewModel? {
        guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
            return nil
        }

        return HomeRecommendationCellHeroWideViewModel(
            recommendation: recommendation,
            overflowActions: overflowActions(for: recommendation, at: indexPath),
            primaryAction: primaryAction(for: recommendation, at: indexPath)
        )
    }

    func recommendationCarouselViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath
    ) -> RecommendationCarouselCell.Model? {
        recommendationHeroViewModel(for: objectID, at: indexPath)
            .flatMap(RecommendationCarouselCell.Model.init)
    }

    private func overflowActions(for recommendation: Recommendation, at indexPath: IndexPath?) -> [ItemAction] {
        guard let indexPath = indexPath else {
            return []
        }

        return [
            .share { [weak self] sender in
                self?.share(recommendation, at: indexPath, with: sender)
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
            let isSaved = recommendation.item?.savedItem != nil
            && recommendation.item?.savedItem?.isArchived == false

            if isSaved {
                self?.archive(recommendation, at: indexPath)
            } else {
                self?.save(recommendation, at: indexPath)
            }
        }
    }

    private func report(_ recommendation: Recommendation, at indexPath: IndexPath) {
        selectedRecommendationToReport = recommendation
    }

    private func share(_ recommendation: Recommendation, at indexPath: IndexPath, with sender: Any?) {
        self.sharedActivity = PocketItemActivity(url: recommendation.item?.bestURL, sender: sender)

        guard
            let item = recommendation.item,
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Shared recommendation without an associated item, slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.Home.SlateArticleShare(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.remoteID))
    }

    private func share(_ savedItem: SavedItem, at indexPath: IndexPath, with sender: Any?) {
        self.sharedActivity = PocketItemActivity(url: savedItem.url, sender: sender)
        tracker.track(event: Events.Home.RecentSavesCardShare(url: savedItem.url, positionInList: indexPath.item))
    }

    private func save(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.save(recommendation: recommendation)

        guard
            let item = recommendation.item,
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Saved recommendation without an associated item, slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.Home.SlateArticleSave(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.remoteID))
    }

    private func archive(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.archive(recommendation: recommendation)

        guard
            let item = recommendation.item,
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Archived recommendation without an associated item, slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.Home.SlateArticleArchive(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.remoteID))
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

            guard
                let item = recommendation.item,
                let slate = recommendation.slate,
                let slateLineup = slate.slateLineup
            else {
                Log.capture(message: "Tried to display recommendation without an associated item, slate and slatelineup, not logging analytics")
                return
            }

            tracker.track(event: Events.Home.SlateArticleImpression(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.remoteID))
        }
    }
}

extension HomeViewModel {
    enum Section: Hashable {
        case loading
        case recentSaves
        case slateHero(NSManagedObjectID)
        case slateCarousel(NSManagedObjectID)
        case offline
    }

    enum Cell: Hashable {
        case loading
        case recentSaves(NSManagedObjectID)
        case recommendationHero(NSManagedObjectID)
        case recommendationCarousel(NSManagedObjectID)
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
        case .recommendation(let viewModel),
                .webViewRecommendation(let viewModel):
            return viewModel.webViewActivityItems(url: url)
        case .savedItem(let viewModel),
                .webViewSavedItem(let viewModel):
            return viewModel.webViewActivityItems(url: url)
        case .none:
            return []
        }
    }
}
