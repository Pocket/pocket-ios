import Sync
import Combine
import UIKit
import CoreData
import Analytics


class HomeViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias ItemIdentifier = NSManagedObjectID
    
    static let lineupIdentifier = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"
    
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
    var selectedReadableViewModel: RecommendationViewModel? = nil

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
            guard var snapshot = self?.buildSnapshot() else { return }
            snapshot.reloadItems([.recentSaves(savedItem.objectID)])
            self?.snapshot = snapshot
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

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return presenter(for: objectID)
    }
    
    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }
    
    func select(cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .recentSaves:
            return
        case .topic:
            guard case .topic(let slate) = cell else { return }
            select(slate: slate)
        case .recommendation:
            select(recommendation: cell, at: indexPath)
        }
    }
    
    func select(slate: Slate) {
        guard let slateID = slate.remoteID else { return }
        
        selectedSlateDetailViewModel = SlateDetailViewModel(
            slateID: slateID,
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
        case .loading, .topic, .recommendation:
            return nil
        }
    }
    
    private func _favorite(item: SavedItem) {
        source.favorite(item: item)
    }

    private func _unfavorite(item: SavedItem) {
        source.unfavorite(item: item)
    }
    
    func overflowActions(for cell: Cell) -> [ItemAction] {
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
        case .loading, .topic, .recommendation:
            return []
        }
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

    func _share(item: SavedItem, sender: Any?) {
        sharedActivity = PocketItemActivity(url: item.url, sender: sender)
    }
    
    func reportAction(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        return .report { [weak self] _ in
            self?.report(cell, at: indexPath)
        }
    }

    func saveAction(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        guard case .recommendation(let objectID) = cell,
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

    func willDisplay(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading, .topic, .recentSaves:
            return
        case .recommendation:
            tracker.track(
                event: ImpressionEvent(component: .content, requirement: .instant),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    func viewModel(for objectID: NSManagedObjectID) -> HomeRecommendationCellViewModel? {
        return viewModels[objectID]
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
        var snapshot = Snapshot()

        let slates = slateLineupController.slateLineup?.slates?.compactMap { $0 as? Slate } ?? []
        
        let recentSavesItemIDs = recentSavesController.recentSaves
            .map({ HomeViewModel.Cell.recentSaves($0.objectID)}) 
        
        if slates.count > 0 {
            snapshot.appendSections([.topics])
        }
        
        if !recentSavesItemIDs.isEmpty {
            snapshot.appendSections([.recentSaves])
            snapshot.appendItems(recentSavesItemIDs, toSection: .recentSaves)
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

            snapshot.appendItems([.topic(slate)], toSection: .topics)

            let slateSection: HomeViewModel.Section = .slate(slate)
            snapshot.appendSections([slateSection])

            recs.forEach { rec in
                let viewModel = HomeRecommendationCellViewModel(recommendation: rec)
                viewModels[rec.objectID] = viewModel

                viewModel.$isSaved.dropFirst().sink { [weak self] isSaved in
                    snapshot.reloadItems([.recommendation(rec.objectID)])
                    self?.snapshot = snapshot
                }.store(in: &viewModelSubscriptions)
            }

            let items = recs.map {
                HomeViewModel.Cell.recommendation($0.objectID)
            }

            snapshot.appendItems(items, toSection: slateSection)
        }

        return snapshot
    }

    private func select(recommendation cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let objectID) = cell,
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
            selectedReadableViewModel = RecommendationViewModel(
                recommendation: viewModel.recommendation,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    private func report(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let objectID) = cell,
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
        guard case .recommendation(let objectID) = cell,
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
        guard case .recommendation(let objectID) = cell,
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
        case .loading, .topic, .recentSaves:
            return []
        case .recommendation(let objectID):
            guard let viewModel = viewModel(for: objectID),
                  case .slate(let slate) = snapshot.sectionIdentifier(containingItem: cell),
                  let slateLineup = slateLineupController.slateLineup,
                  let slateIndex = snapshot.indexOfSection(.slate(slate)),
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
}

extension HomeViewModel {
    enum Section: Hashable {
        case loading
        case topics
        case recentSaves
        case slate(Slate)
    }

    enum Cell: Hashable {
        case loading
        case topic(Slate)
        case recentSaves(NSManagedObjectID)
        case recommendation(NSManagedObjectID)
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
