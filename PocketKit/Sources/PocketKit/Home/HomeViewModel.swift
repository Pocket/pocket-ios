import Sync
import Combine
import UIKit
import CoreData
import Analytics

enum ReadableType {
    case recommendation(RecommendationViewModel)
    case savedItem(SavedItemViewModel)

    func clearIsPresentingReaderSettings() {
        switch self {
        case .recommendation(let recommendationViewModel):
            recommendationViewModel.clearIsPresentingReaderSettings()
        case .savedItem(let savedItemViewModel):
            savedItemViewModel.clearIsPresentingReaderSettings()
        }
    }
}

enum SeeAll {
    case myList
    case slate(SlateDetailViewModel)

    func clearRecommendationToReport() {
        switch self {
        case .myList:
            break
        case .slate(let viewModel):
            viewModel.clearRecommendationToReport()
        }
    }

    func clearPresentedWebReaderURL() {
        switch self {
        case .myList:
            break
        case .slate(let viewModel):
            viewModel.clearPresentedWebReaderURL()
        }
    }

    func clearSharedActivity() {
        switch self {
        case .myList:
            break
        case .slate(let viewModel):
            viewModel.clearSharedActivity()
        }
    }

    func clearIsPresentingReaderSettings() {
        switch self {
        case .myList:
            break
        case .slate(let viewModel):
            viewModel.clearIsPresentingReaderSettings()
        }
    }

    func clearSelectedItem() {
        switch self {
        case .myList:
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
    var presentedWebReaderURL: URL?

    @Published
    var tappedSeeAll: SeeAll?

    private let source: Source
    private let tracker: Tracker
    private let networkPathMonitor: NetworkPathMonitor
    private var subscriptions: [AnyCancellable] = []
    private var recentSavesCount: Int = 0

    init(
        source: Source,
        tracker: Tracker,
        networkPathMonitor: NetworkPathMonitor
    ) {
        self.source = source
        self.tracker = tracker
        self.networkPathMonitor = networkPathMonitor
        networkPathMonitor.start(queue: .global())

        self.snapshot = {
            return Self.loadingSnapshot()
        }()

        NotificationCenter.default.publisher(
            for: NSManagedObjectContext.didSaveObjectsNotification,
            object: source.mainContext
        ).sink { [weak self] notification in
            do {
                try self?.handle(notification: notification)
            } catch {
                print(error)
            }
        }.store(in: &subscriptions)

        networkPathMonitor.updateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.refresh { }
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
            print(error)
        }
    }

    func refresh(_ completion: @escaping () -> Void) {
        guard !isOffline else {
            do {
                snapshot = try rebuildSnapshot()
            } catch {
                print(error)
            }

            completion()
            return
        }

        Task {
            try await source.fetchSlateLineup(Self.lineupIdentifier)
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
        let recentSavesRequest = Requests.fetchSavedItems(limit: 5)
        let recentSaves = try source.mainContext.fetch(recentSavesRequest)
        let slateLineupRequest = Requests.fetchSlateLineup(byID: Self.lineupIdentifier)
        let slateLineup = try source.mainContext.fetch(slateLineupRequest).first

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
            guard let savedItem = source.mainContext.object(with: objectID) as? SavedItem else {
                return
            }

            select(savedItem: savedItem, at: indexPath)
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
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
        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: recommendation, at: indexPath)
        )

        let item = recommendation.item

        if item?.shouldOpenInWebView == true {
            presentedWebReaderURL = item?.bestURL
            tracker.track(
                event: ContentOpenEvent(destination: .external, trigger: .click),
                contexts(for: recommendation, at: indexPath)
            )
        } else {
            let viewModel = RecommendationViewModel(
                recommendation: recommendation,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general
            )
            selectedReadableType = .recommendation(viewModel)

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: recommendation, at: indexPath)
            )
        }
    }

    private func select(savedItem: SavedItem, at indexPath: IndexPath) {
        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: savedItem, at: indexPath)
        )

        if let item = savedItem.item, item.shouldOpenInWebView {
            presentedWebReaderURL = item.bestURL

            tracker.track(
                event: ContentOpenEvent(destination: .external, trigger: .click),
                contexts(for: savedItem, at: indexPath)
            )
        } else {
            let viewModel = SavedItemViewModel(
                item: savedItem,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general
            )
            selectedReadableType = .savedItem(viewModel)

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: savedItem, at: indexPath)
            )
        }
    }
}

// MARK: - Section Headers
extension HomeViewModel {
    func sectionHeaderViewModel(for section: Section) -> SectionHeaderView.Model? {
        switch section {
        case .recentSaves:
            return .init(
                name: "Recent Saves",
                buttonTitle: "My List",
                buttonImage: nil
            ) { [weak self] in
                self?.tappedSeeAll = .myList
            }
        case .slateHero(let objectID):
            guard let slate = source.mainContext.object(with: objectID) as? Slate else {
                return nil
            }

            return .init(
                name: slate.name ?? "",
                buttonTitle: "See All",
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
        guard let savedItem = source.mainContext.object(with: objectID) as? SavedItem else {
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
                    self?.sharedActivity = PocketItemActivity(url: savedItem.url, sender: sender)
                },
                .archive { [weak self] _ in
                    self?.source.archive(item: savedItem)
                },
                .delete { [weak self] _ in
                    self?.confirmDelete(item: savedItem)
                }
            ]
        )
    }

    private func confirmDelete(item: SavedItem) {
        presentedAlert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: "No", style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                    self?.presentedAlert = nil
                    self?.delete(item: item)
                }
            ],
            preferredAction: nil
        )
    }

    private func delete(item: SavedItem) {
        presentedAlert = nil
        source.delete(item: item)
    }

    func contexts(for savedItem: SavedItem, at indexPath: IndexPath) -> [Context] {
        guard let url = savedItem.bestURL else { return [] }

        return [
            ContentContext(url: url),
            UIContext.home.recentSave(index: UIIndex(indexPath.item))
        ]
    }
}

// MARK: - Slate Model
extension HomeViewModel {
    func slateModel(for objectID: NSManagedObjectID) -> Slate? {
        return source.mainContext.object(with: objectID) as? Slate
    }
}

// MARK: Recommendation View Model & Actions
extension HomeViewModel {
    func numberOfCarouselItemsForSlate(with id: NSManagedObjectID) -> Int {
        let count = (source.mainContext.object(with: id) as? Slate)?
            .recommendations?.count ?? 0

        return max(0, count - 1)
    }

    func recommendationHeroViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeRecommendationCellViewModel? {
        guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
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
        guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
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
                self?.sharedActivity = PocketItemActivity(url: recommendation.item?.bestURL, sender: sender)
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
        tracker.track(
            event: SnowplowEngagement(type: .report, value: nil),
            contexts(for: recommendation, at: indexPath)
        )

        selectedRecommendationToReport = recommendation
    }

    private func save(_ recommendation: Recommendation, at indexPath: IndexPath) {
        let contexts = contexts(for: recommendation, at: indexPath) + [UIContext.button(identifier: .itemSave)]

        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.save(recommendation: recommendation)
    }

    private func archive(_ recommendation: Recommendation, at indexPath: IndexPath) {
        let contexts = contexts(for: recommendation, at: indexPath) + [UIContext.button(identifier: .itemArchive)]
        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.archive(recommendation: recommendation)
    }

    private func contexts(for recommendation: Recommendation, at indexPath: IndexPath) -> [Context] {
        guard let slate = recommendation.slate,
              let slateLineup = slate.slateLineup,
              let recommendationURL = recommendation.item?.bestURL else {
            return []
        }

        var contexts: [Context] = []

        // SlateLineup Context
        if  let id = slateLineup.remoteID,
            let requestID = slateLineup.requestID,
            let experimentID = slateLineup.experimentID {

            let context = SlateLineupContext(
                id: id,
                requestID: requestID,
                experiment: experimentID
            )
            contexts.append(context)
        }

        // Slate context
        if let slateID = slate.remoteID,
           let requestID = slate.requestID,
           let experimentID = slate.experimentID,
           let slateIndex = slateLineup.slates?.index(of: slate) {

            let slateContext = SlateContext(
                id: slateID,
                requestID: requestID,
                experiment: experimentID,
                index: UIIndex(slateIndex)
            )
            contexts.append(slateContext)
        }

        // Recommendation context
        if let recommendationID = recommendation.remoteID,
           let recommendationIndex = slate.recommendations?.index(of: recommendation) {

            let recommendationContext = RecommendationContext(
                id: recommendationID,
                index: UIIndex(recommendationIndex)
            )
            contexts.append(recommendationContext)
        }

        return contexts + [
            ContentContext(url: recommendationURL),
            UIContext.home.item(index: UIIndex(indexPath.item))
        ]
    }
}

// MARK: - Cell Lifecycle
extension HomeViewModel {
    func willDisplay(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .recentSaves, .offline:
            return
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
                return
            }

            tracker.track(
                event: ImpressionEvent(component: .content, requirement: .instant),
                contexts(for: recommendation, at: indexPath)
            )
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
        presentedWebReaderURL = nil
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
