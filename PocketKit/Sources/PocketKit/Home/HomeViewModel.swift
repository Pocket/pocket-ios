import Sync
import Combine
import UIKit
import CoreData
import Analytics


enum ReadableType {
    case recommendation(RecommendationViewModel)
    case savedItem(SavedItemViewModel)
}

class HomeViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias ItemIdentifier = NSManagedObjectID
    
    static let lineupIdentifier = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"
    
    var recentSavesViewModels: [NSManagedObjectID: RecentSavesItemCell.Model] = [:]
    
    private let source: Source
    private let slateLineupController: SlateLineupController
    private let tracker: Tracker

    @Published
    var snapshot: Snapshot
    
    @Published
    var sharedActivity: PocketActivity?
    
    @Published
    var presentedAlert: PocketAlert?

    @Published
    var selectedReadableType: ReadableType? = nil

    @Published
    var selectedRecommendationToReport: Recommendation? = nil

    @Published
    var selectedSlateDetailViewModel: SlateDetailViewModel? = nil

    @Published
    var presentedWebReaderURL: URL? = nil
    
    @Published
    var tappedSeeAll: Section? = nil

    private var viewModels: [NSManagedObjectID: HomeRecommendationCellViewModel] = [:]
    private var viewModelSubscriptions: Set<AnyCancellable> = []
    private let recentSavesController: RecentSavesController
    private var subscriptions: [AnyCancellable] = []
    
    init(
        source: Source,
        tracker: Tracker
    ) {
        self.source = source
        self.tracker = tracker
        self.slateLineupController = source.makeSlateLineupController()
        self.recentSavesController = source.makeRecentSavesController()

        self.snapshot = Self.loadingSnapshot()
        
        self.slateLineupController.delegate = self
        
        recentSavesController.$recentSaves.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.itemsLoaded()
        }.store(in: &subscriptions)
        
        recentSavesController.itemChanged.receive(on: DispatchQueue.main).sink { [weak self] savedItem in
            let item = Cell.recentSaves(savedItem.objectID)
            if self?.snapshot.indexOfItem(item) != nil {
                self?.snapshot.reloadItems([item])
            }
        }.store(in: &subscriptions)
    }

    func fetch() {
        try? slateLineupController.performFetch()
    }

    func refresh(_ completion: @escaping () -> Void) {
        // By emptying out our view models and their subscriptions,
        // we are ensuring that no previously existing view models
        // publish changes when source.fetchSlateLineup cascades and deletes any
        // unsaved items (see HomeRecommendationCellViewModel.init(recommendation:)).
        // This would cause an erroneous snapshot to be published
        // (potentially while another snapshot was still being applied).
        viewModels = [:]
        viewModelSubscriptions = []

        Task {
            try await source.fetchSlateLineup(Self.lineupIdentifier)
            completion()
        }
    }
    
    func select(cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recentSaves:
            select(recentSave: cell, at: indexPath)
        case .recommendationHero, .recommendationCarousel:
            select(recommendation: cell, at: indexPath)
        }
    }
    
    func select(slate: Slate) {
        guard let slateID = slate.remoteID else { return }
        
        selectedSlateDetailViewModel = SlateDetailViewModel(
            slateID: slateID,
            slateName: slate.name,
            source: source,
            tracker: tracker.childTracker(hosting: .slateDetail.screen)
        )
    }
    
    func favoriteAction(for cell: Cell) -> ItemAction? {
        switch cell {
        case .recentSaves(let objectID):
            guard let item = bareItem(with: objectID) else {
                return nil
            }

            if item.isFavorite {
                return .unfavorite { [weak self] _ in self?._unfavorite(item: item) }
            } else {
                return .favorite { [weak self] _ in self?._favorite(item: item) }
            }
        case .loading, .recommendationHero, .recommendationCarousel:
            return nil
        }
    }
    
    private func _favorite(item: SavedItem) {
        source.favorite(item: item)
    }

    private func _unfavorite(item: SavedItem) {
        source.unfavorite(item: item)
    }
    
    func overflowActions(for cell: Cell, at indexPath: IndexPath) -> [ItemAction] {
        switch cell {
        case .recentSaves(let objectID):
            guard let item = bareItem(with: objectID) else {
                return []
            }

            return [
                .share { [weak self] sender in
                    self?._share(item: item, sender: sender)
                },
                .archive { [weak self] _ in
                    self?._archive(item: item)
                },
                .delete { [weak self] _ in
                    self?.confirmDelete(item: item)
                }
            ]
        case .recommendationHero, .recommendationCarousel:
            guard let itemAction = reportAction(for: cell, at: indexPath) else { return [] }
            return [itemAction]
        case .loading:
            return []
        }
    }
        
    private func _share(item: SavedItem, sender: Any?) {
        sharedActivity = PocketItemActivity(url: item.url, sender: sender)
    }
    
    private func _archive(item: SavedItem) {
        source.archive(item: item)
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
                    self?._delete(item: item)
                }
            ],
            preferredAction: nil
        )
    }
    
    private func _delete(item: SavedItem) {
        presentedAlert = nil
        source.delete(item: item)
    }

    func reportAction(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        return .report { [weak self] _ in
            self?.report(cell, at: indexPath)
        }
    }

    func saveAction(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        guard let objectID = getRecommendationID(with: cell),
              let viewModel = viewModel(for: objectID) else {
            return nil
        }

        return .recommendationPrimary { [weak self] _ in
            if viewModel.isSaved {
                self?.archive(cell, at: indexPath)
            } else {
                self?.save(cell, at: indexPath)
            }
        }
    }
    
    private func getRecommendationID(with cell: HomeViewModel.Cell) -> NSManagedObjectID? {
        switch cell {
        case .recommendationHero(let objectID):
            return objectID
        case .recommendationCarousel(let objectID):
            return objectID
        default:
            return nil
        }
    }

    func willDisplay(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .recentSaves:
            return
        case .recommendationHero, .recommendationCarousel:
            tracker.track(
                event: ImpressionEvent(component: .content, requirement: .instant),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    func viewModel(for objectID: NSManagedObjectID) -> HomeRecommendationCellViewModel? {
        return viewModels[objectID]
    }
    
    func recommendationHeroViewModel(for objectID: NSManagedObjectID, and item: HomeViewModel.Cell, at indexPath: IndexPath) -> HomeRecommendationCellViewModel? {
        guard let viewModel = viewModels[objectID] else { return nil }
        viewModel.overflowActions = overflowActions(for: item, at: indexPath)
        viewModel.saveAction = saveAction(for: item, at: indexPath)
        return viewModel
    }
    
    func recentSavesViewModel(for objectID: NSManagedObjectID, and item: HomeViewModel.Cell, at indexPath: IndexPath) -> RecentSavesItemCell.Model? {
        var viewModel = recentSavesViewModels[objectID]
        viewModel?.favoriteAction = favoriteAction(for: item)
        viewModel?.overflowActions = overflowActions(for: item, at: indexPath)
        return viewModel
    }
    
    func recommendationCarouselViewModel(for objectID: NSManagedObjectID, and item: HomeViewModel.Cell, at indexPath: IndexPath) -> RecommendationCarouselCell.Model? {
        guard let recommendationCellViewModel = viewModels[objectID] else { return nil }
        var viewModel = RecommendationCarouselCell.Model(viewModel: recommendationCellViewModel)
        viewModel.overflowActions = overflowActions(for: item, at: indexPath)
        viewModel.saveAction = saveAction(for: item, at: indexPath)
        return viewModel
    }
}

extension HomeViewModel {
    private static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.object(id: id)
    }
    
    private func itemsLoaded() {
        snapshot = buildSnapshot()
    }
    
    private func buildSnapshot() -> Snapshot {
        viewModels = [:]
        viewModelSubscriptions = []
        recentSavesViewModels = [:]
        var snapshot = Snapshot()

        let slates = slateLineupController.slateLineup?.slates?.compactMap { $0 as? Slate } ?? []
        
        let recentSavesItemIDs = recentSavesController.recentSaves
            .map({ HomeViewModel.Cell.recentSaves($0.objectID)})
        
        if !recentSavesItemIDs.isEmpty {
            snapshot.appendSections([.recentSaves])
            snapshot.appendItems(recentSavesItemIDs, toSection: .recentSaves)
            recentSavesController.recentSaves.forEach { item in
                let viewModel = RecentSavesItemCell.Model(item: item)
                recentSavesViewModels[item.objectID] = viewModel
            }
        }
        
        slates.forEach { slate in
            // Create a topic and slate section _only_ if any
            // recommendations exist for the given slate
            let recs = slate.recommendations?
                .compactMap { $0 as? Recommendation }
            ?? []

            guard recs.isEmpty == false else {
                return
            }

            let slateHeroSection: HomeViewModel.Section = .slateHero(slate.objectID)
            let slateCarouselSection: HomeViewModel.Section = .slateCarousel(slate.objectID)
            
            snapshot.appendSections([slateHeroSection])
            snapshot.appendItems([.recommendationHero(recs[0].objectID)], toSection: slateHeroSection)
            
            if recs.count > 1 {
                snapshot.appendSections([slateCarouselSection])
                
                let carouselItems = recs[1...].map {
                    HomeViewModel.Cell.recommendationCarousel($0.objectID)
                }

                snapshot.appendItems(carouselItems, toSection: slateCarouselSection)
            }

            recs.forEach { rec in
                let viewModel = HomeRecommendationCellViewModel(recommendation: rec)
                viewModels[rec.objectID] = viewModel

                viewModel.updated.sink { [weak self] isSaved in
                    let heroItem = Cell.recommendationHero(rec.objectID)
                    let carouselItem = Cell.recommendationCarousel(rec.objectID)
                    if self?.snapshot.indexOfItem(heroItem) != nil {
                        self?.snapshot.reloadItems([heroItem])
                    }
                    if self?.snapshot.indexOfItem(carouselItem) != nil {
                        self?.snapshot.reloadItems([carouselItem])
                    }
                }.store(in: &viewModelSubscriptions)
            }
        }

        return snapshot
    }
    
    func numberOfCarouselItemsForSlate(with id: NSManagedObjectID) -> Int {
        let slate: Slate? = source.object(id: id)
                
        guard let count = slate?.recommendations?.count,
        count > 1 else {
            return 0
        }

        return count - 1
    }
    
    func numberOfRecentSavesItem() -> Int {
//        guard snapshot.indexOfSection(.recentSaves) != nil else { return 0 }
//        return snapshot.itemIdentifiers(inSection: .recentSaves).count
        return 5
    }
    
    func slate(with id: NSManagedObjectID) -> Slate? {
        let slate: Slate? = source.object(id: id)
        return slate
    }

    private func select(recommendation cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard let objectID = getRecommendationID(with: cell),
              let viewModel = viewModel(for: objectID) else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: cell, at: indexPath)
        )

        let item = viewModel.recommendation.item
        if let isArticle = item?.isArticle, isArticle == false
            || item?.hasImage == .isImage
            || item?.hasVideo == .isVideo {
            presentedWebReaderURL = item?.bestURL

            tracker.track(
                event: ContentOpenEvent(destination: .external, trigger: .click),
                contexts(for: cell, at: indexPath)
            )
        } else {
            let viewModel = RecommendationViewModel(
                recommendation: viewModel.recommendation,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
            selectedReadableType = .recommendation(viewModel)

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    private func select(recentSave cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recentSaves(let objectID) = cell,
        let savedItem = bareItem(with: objectID) else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: cell, at: indexPath)
        )

        if let item = savedItem.item, item.shouldOpenInWebView {
            presentedWebReaderURL = item.bestURL

            tracker.track(
                event: ContentOpenEvent(destination: .external, trigger: .click),
                contexts(for: cell, at: indexPath)
            )
        } else {
            let viewModel = SavedItemViewModel(
                item: savedItem,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
            selectedReadableType = .savedItem(viewModel)

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    private func report(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard let objectID = getRecommendationID(with: cell),
              let viewModel = viewModel(for: objectID) else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .report, value: nil),
            contexts(for: cell, at: indexPath)
        )
        selectedRecommendationToReport = viewModel.recommendation
    }

    private func save(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard let objectID = getRecommendationID(with: cell),
              let viewModel = viewModel(for: objectID) else {
            return
        }

        let contexts = contexts(for: cell, at: indexPath) + [UIContext.button(identifier: .itemSave)]
        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.save(recommendation: viewModel.recommendation)
    }

    private func archive(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard let objectID = getRecommendationID(with: cell),
              let viewModel = viewModel(for: objectID) else {
            return
        }

        let contexts = contexts(for: cell, at: indexPath) + [UIContext.button(identifier: .itemArchive)]
        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.archive(recommendation: viewModel.recommendation)
    }

    private func contexts(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> [Context] {
        switch cell {
        case .loading:
            return []
        case .recentSaves:
            guard case .recentSaves(let objectID) = cell,
                  let savedItem = bareItem(with: objectID),
                  let contextURL = savedItem.bestURL else {
                return []
            }

            let contentContext = ContentContext(url: contextURL)
            let itemContext = UIContext.home.recentSave(index: UIIndex(indexPath.item))
            return [itemContext, contentContext]
        case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
            guard let viewModel = viewModel(for: objectID),
                  let slate = getSlateDetails(with: cell)?.0, let slateIndex = getSlateDetails(with: cell)?.1,
                  let slateLineup = slateLineupController.slateLineup,
                  let recommendationURL = viewModel.recommendation.item?.bestURL else {
                return []
            }

            let lineupContext = SlateLineupContext(
                id: Self.lineupIdentifier,
                requestID: slateLineup.requestID!,
                experiment: slateLineup.experimentID!
            )

            let slateContext = SlateContext(
                id: slate.remoteID!,
                requestID: slate.requestID!,
                experiment: slate.experimentID!,
                index: UIIndex(slateIndex)
            )

            let recommendationContext = RecommendationContext(
                id: viewModel.recommendation.remoteID!,
                index: UIIndex(indexPath.item)
            )

            let contentContext = ContentContext(url: recommendationURL)
            let itemContext = UIContext.home.item(index: UIIndex(indexPath.item))

            return [lineupContext, slateContext, recommendationContext, contentContext, itemContext]
        }
    }
    
    private func getSlateDetails(with cell: HomeViewModel.Cell) -> (Slate?, Int?)? {
        switch snapshot.sectionIdentifier(containingItem: cell) {
        case .slateHero(let slateID):
            let slateIndex = snapshot.indexOfSection(.slateHero(slateID))
            return (slate(with: slateID), slateIndex)
        case .slateCarousel(let slateID):
            let slateIndex = snapshot.indexOfSection(.slateCarousel(slateID))
            return (slate(with: slateID), slateIndex)
        default:
            return nil
        }
    }
}

extension HomeViewModel {
    enum Section: Hashable {
        case loading
        case recentSaves
        case slateHero(NSManagedObjectID)
        case slateCarousel(NSManagedObjectID)
    }

    enum Cell: Hashable {
        case loading
        case recentSaves(NSManagedObjectID)
        case recommendationHero(NSManagedObjectID)
        case recommendationCarousel(NSManagedObjectID)
    }
}

extension HomeViewModel: SlateLineupControllerDelegate {
    func controller(
        _ controller: SlateLineupController,
        didChange slateLineup: SlateLineup,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {

    }

    func controllerDidChangeContent(_ controller: SlateLineupController) {
        itemsLoaded()
    }
}
