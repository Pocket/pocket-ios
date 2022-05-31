import Sync
import Combine
import UIKit
import CoreData
import Analytics


class HomeViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    static let lineupIdentifier = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"

    private let source: Source
    private let slateLineupController: SlateLineupController
    private let tracker: Tracker

    @Published
    var snapshot = Snapshot()

    @Published
    var selectedReadableViewModel: RecommendationViewModel? = nil

    @Published
    var selectedRecommendationToReport: Recommendation? = nil

    @Published
    var selectedSlateDetailViewModel: SlateDetailViewModel? = nil

    @Published
    var presentedWebReaderURL: URL? = nil

    private var viewModels: [NSManagedObjectID: HomeRecommendationCellViewModel] = [:]
    private var viewModelSubscriptions: Set<AnyCancellable> = []

    init(
        source: Source,
        tracker: Tracker
    ) {
        self.source = source
        self.tracker = tracker
        self.slateLineupController = source.makeSlateLineupController()

        self.slateLineupController.delegate = self
    }

    func fetch() {
        try? slateLineupController.performFetch()
    }

    func refresh(_ completion: @escaping () -> Void) {
        Task {
            try await source.fetchSlateLineup(Self.lineupIdentifier)
            completion()
        }
    }

    func select(cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .topic:
            select(topic: cell)
        case .recommendation:
            select(recommendation: cell, at: indexPath)
        }
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
        case .topic:
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
    private func buildSnapshot() -> Snapshot {
        viewModels = [:]
        viewModelSubscriptions = []
        var snapshot = Snapshot()

        let slates = slateLineupController.slateLineup?.slates?.compactMap { $0 as? Slate } ?? []

        if slates.count > 0 {
            snapshot.appendSections([.topics])
        }

        slates.forEach { slate in
            snapshot.appendItems([.topic(slate)], toSection: .topics)

            let slateSection: HomeViewModel.Section = .slate(slate)
            snapshot.appendSections([slateSection])

            let recs = slate.recommendations?
                .compactMap { $0 as? Recommendation }
            ?? []

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

    private func select(topic cell: HomeViewModel.Cell) {
        guard case .topic(let slate) = cell,
              let slateID = slate.remoteID else {
                  return
              }

        selectedSlateDetailViewModel = SlateDetailViewModel(
            slateID: slateID,
            source: source,
            tracker: tracker.childTracker(hosting: .slateDetail.screen)
        )
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
        case .topic:
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
        case topics
        case slate(Slate)
    }

    enum Cell: Hashable {
        case topic(Slate)
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
        snapshot = buildSnapshot()
    }
}
