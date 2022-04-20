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
        guard case .recommendation(let viewModel) = cell else {
            return nil
        }

        if viewModel.isSaved {
            return .archive { [weak self] _ in
                self?.archive(cell, at: indexPath)
            }
        } else {
            return .save { [weak self] _ in
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
}

extension HomeViewModel {
    private func buildSnapshot() -> Snapshot {
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

            let viewModels = slate.recommendations?
                .compactMap { $0 as? Recommendation }
                .map { HomeRecommendationCellViewModel(recommendation: $0) }
            ?? []

            let items = viewModels.map { viewModel in
                return HomeViewModel.Cell.recommendation(HomeRecommendationCellViewModel(recommendation: viewModel.recommendation))
            }
            snapshot.appendItems(items, toSection: slateSection)

            viewModels.forEach { viewModel in
                viewModel.$isSaved.dropFirst().sink { [weak self] isSaved in
                    snapshot.reloadItems([.recommendation(viewModel)])
                    self?.snapshot = snapshot
                }.store(in: &viewModelSubscriptions)
            }
        }

        return snapshot
    }

    private func select(recommendation cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let recommendation) = cell else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: cell, at: indexPath)
        )

        let item = recommendation.recommendation.item
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
                recommendation: recommendation.recommendation,
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
              let id = slate.remoteID else {
                  return
              }

        selectedSlateDetailViewModel = SlateDetailViewModel(slateID: id)
    }

    private func report(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let recommendation) = cell else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .report, value: nil),
            contexts(for: cell, at: indexPath)
        )
        selectedRecommendationToReport = recommendation.recommendation
    }

    private func save(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let recommendation) = cell else {
            return
        }

        let contexts = contexts(for: cell, at: indexPath) + [UIContext.button(identifier: .itemSave)]
        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.save(recommendation: recommendation.recommendation)
    }

    private func archive(_ cell: HomeViewModel.Cell, at indexPath: IndexPath) {
        guard case .recommendation(let recommendation) = cell else {
            return
        }

        let contexts = contexts(for: cell, at: indexPath) + [UIContext.button(identifier: .itemArchive)]
        tracker.track(
            event: SnowplowEngagement(type: .save, value: nil),
            contexts
        )

        source.archive(recommendation: recommendation.recommendation)
    }

    private func contexts(for cell: HomeViewModel.Cell, at indexPath: IndexPath) -> [Context] {
        switch cell {
        case .topic:
            return []
        case .recommendation(let recommendation):
            guard case .slate(let slate) = snapshot.sectionIdentifier(containingItem: cell),
                  let slateLineup = slateLineupController.slateLineup,
                  let slateIndex = snapshot.indexOfSection(.slate(slate)),
                  let recommendationURL = recommendation.recommendation.item?.bestURL else {
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
                id: recommendation.recommendation.remoteID!,
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
        case recommendation(HomeRecommendationCellViewModel)
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
