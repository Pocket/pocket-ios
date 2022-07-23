import Foundation
import Sync
import UIKit
import CoreData
import Combine
import Analytics


class SlateDetailViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    private let slateID: String
    private let source: Source
    private let tracker: Tracker
    private let slateController: SlateController

    private var viewModels: [NSManagedObjectID: HomeRecommendationCellViewModel] = [:]
    private var viewModelSubscriptions: Set<AnyCancellable> = []

    @Published
    var snapshot: Snapshot

    @Published
    var selectedReadableViewModel: RecommendationViewModel? = nil

    @Published
    var presentedWebReaderURL: URL? = nil

    @Published
    var selectedRecommendationToReport: Recommendation? = nil

    init(slateID: String, source: Source, tracker: Tracker) {
        self.slateID = slateID
        self.source = source
        self.tracker = tracker
        self.slateController = source.makeSlateController(byID: slateID)
        self.snapshot = Self.loadingSnapshot()

        self.slateController.delegate = self
    }

    func fetch() {
        try? slateController.performFetch()
    }

    func refresh(_ completion: @escaping () -> Void) {
        Task {
            try await source.fetchSlate(slateID)
            completion()
        }
    }

    func select(cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recommendation:
            select(recommendation: cell, at: indexPath)
        }
    }

    func reportAction(for cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        return .report { [weak self] _ in
            self?.report(cell, at: indexPath)
        }
    }

    func saveAction(for cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) -> ItemAction? {
        guard case .recommendation(let objectID) = cell,
              let viewModel = viewModel(for: objectID) else {
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

    func willDisplay(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recommendation:
            tracker.track(
                event: ImpressionEvent(component: .content, requirement: .instant),
                contexts(for: cell, at: indexPath)
            )
        }
    }

    func resetSlate(keeping count: Int) {
        let recommendations = slateController.slate?.recommendations?.compactMap { $0 as? Recommendation} ?? []
        let toRemove = recommendations.dropFirst(count)
        toRemove.forEach {
            source.remove(recommendation: $0)
        }
    }

    func viewModel(for objectID: NSManagedObjectID) -> HomeRecommendationCellViewModel? {
        return viewModels[objectID]
    }
}

private extension SlateDetailViewModel {
    static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
    }

    func buildSnapshot() -> Snapshot {
        viewModels = [:]
        viewModelSubscriptions = []

        let recommendations = slateController.slate?.recommendations?
            .compactMap { $0 as? Recommendation }
        ?? []

        var snapshot = Snapshot()

        guard let slate = slateController.slate else {
            return snapshot
        }

        let section: SlateDetailViewModel.Section = .slate(slate)
        snapshot.appendSections([section])
        recommendations.forEach { recommendation in
            let viewModel = HomeRecommendationCellViewModel(recommendation: recommendation)
            viewModels[recommendation.objectID] = viewModel
            snapshot.appendItems(
                [.recommendation(recommendation.objectID)],
                toSection: section
            )

            viewModel.updated.sink { [weak self] in
                let item: SlateDetailViewModel.Cell = .recommendation(recommendation.objectID)
                if self?.snapshot.indexOfItem(item) != nil {
                    self?.snapshot.reloadItems([item])
                }
            }.store(in: &viewModelSubscriptions)
        }

        return snapshot
    }

    private func select(recommendation cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
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

    private func report(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
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

    private func save(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
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

    private func archive(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
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

    private func contexts(for cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) -> [Context] {
        switch cell {
        case .loading:
            return []
        case .recommendation(let objectID):
            guard let viewModel = viewModel(for: objectID),
                  let slate = slateController.slate,
                  let recommendationURL = viewModel.recommendation.item?.bestURL else {
                return []
            }

            let slateContext = SlateContext(
                id: slate.remoteID!,
                requestID: slate.requestID!,
                experiment: slate.experimentID!,
                index: UIIndex(0)
            )

            let recommendationContext = RecommendationContext(
                id: viewModel.recommendation.remoteID!,
                index: UIIndex(indexPath.item)
            )

            let contentContext = ContentContext(url: recommendationURL)
            let itemContext = UIContext.slateDetail.recommendation(index: UIIndex(indexPath.item))

            return [slateContext, recommendationContext, contentContext, itemContext]
        }
    }
}

extension SlateDetailViewModel: SlateControllerDelegate {
    func controllerDidChangeContent(_ controller: SlateController) {
        snapshot = buildSnapshot()
    }

    func controller(
        _ controller: SlateController,
        didChange slate: Slate,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        snapshot = buildSnapshot()
    }
}

extension SlateDetailViewModel {
    enum Section: Hashable {
        case loading
        case slate(Slate)
    }

    enum Cell: Hashable {
        case loading
        case recommendation(NSManagedObjectID)
    }
}
