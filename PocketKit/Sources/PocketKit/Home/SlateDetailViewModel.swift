import Foundation
import Sync
import UIKit
import CoreData
import Combine
import Analytics

class SlateDetailViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published
    var snapshot: Snapshot

    @Published
    var selectedReadableViewModel: RecommendationViewModel?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var selectedRecommendationToReport: Recommendation?

    @Published
    var sharedActivity: PocketActivity?

    var slateName: String? {
        slate.name
    }

    private let slate: Slate
    private let source: Source
    private let tracker: Tracker
    private var subscriptions: [AnyCancellable] = []

    init(slate: Slate, source: Source, tracker: Tracker) {
        self.slate = slate
        self.source = source
        self.tracker = tracker
        self.snapshot = Self.loadingSnapshot()

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
    }

    func fetch() {
        let snapshot = buildSnapshot()
        guard snapshot.numberOfItems != 0 else { return }
        self.snapshot = snapshot
    }

    func refresh(_ completion: @escaping () -> Void) {
        guard let slateID = slate.remoteID else {
            return
        }

        Task {
            try await source.fetchSlate(slateID)
            completion()
        }
    }

    func willDisplay(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recommendation(let objectID):
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

// MARK: - Cell Selection
extension SlateDetailViewModel {
    func select(cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recommendation(let objectID):
            selectRecommendation(with: objectID, at: indexPath)
        }
    }

    private func selectRecommendation(with objectID: NSManagedObjectID, at indexPath: IndexPath) {
        guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
            return
        }

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts(for: recommendation, at: indexPath)
        )

        if let item = recommendation.item, item.shouldOpenInWebView {
            presentedWebReaderURL = item.bestURL

            tracker.track(
                event: ContentOpenEvent(destination: .external, trigger: .click),
                contexts(for: recommendation, at: indexPath)
            )
        } else {
            selectedReadableViewModel = RecommendationViewModel(
                recommendation: recommendation,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general
            )

            tracker.track(
                event: ContentOpenEvent(destination: .internal, trigger: .click),
                contexts(for: recommendation, at: indexPath)
            )
        }
    }
}

// MARK: View model and actions
extension SlateDetailViewModel {
    func recommendationViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeRecommendationCellViewModel? {
        guard let recommendation = source.mainContext.object(with: objectID) as? Recommendation else {
            return nil
        }

        guard let indexPath = indexPath else {
            return HomeRecommendationCellViewModel(recommendation: recommendation)
        }

        return HomeRecommendationCellViewModel(
            recommendation: recommendation,
            overflowActions: [
                .share { [weak self] sender in
                    self?.sharedActivity = PocketItemActivity(url: recommendation.item?.bestURL, sender: sender)
                },
                .report { [weak self] _ in
                    self?.report(recommendation, at: indexPath)
                }
            ],
            primaryAction: .recommendationPrimary { [weak self] _ in
                let isSaved = recommendation.item?.savedItem != nil
                && recommendation.item?.savedItem?.isArchived == false

                if isSaved {
                    self?.archive(recommendation, at: indexPath)
                } else {
                    self?.save(recommendation, at: indexPath)
                }
            }
        )
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

    private func report(_ recommendation: Recommendation, at indexPath: IndexPath) {
        tracker.track(
            event: SnowplowEngagement(type: .report, value: nil),
            contexts(for: recommendation, at: indexPath)
        )

        selectedRecommendationToReport = recommendation
    }

    private func contexts(for recommendation: Recommendation, at indexPath: IndexPath) -> [Context] {
        guard let recommendationURL = recommendation.item?.bestURL else {
            return []
        }

        var contexts: [Context] = []

        if let remoteID = slate.remoteID,
           let requestID = slate.requestID,
           let experimentID = slate.experimentID {

            let slateContext = SlateContext(
                id: remoteID,
                requestID: requestID,
                experiment: experimentID,
                index: UIIndex(0)
            )
            contexts.append(slateContext)
        }

        if let remoteID = recommendation.remoteID {
            let recommendationContext = RecommendationContext(
                id: remoteID,
                index: UIIndex(indexPath.item)
            )
            contexts.append(recommendationContext)
        }

        return contexts + [
            ContentContext(url: recommendationURL),
            UIContext.slateDetail.recommendation(index: UIIndex(indexPath.item))
        ]
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
        var snapshot = Snapshot()
        let recommendations = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []

        let section: SlateDetailViewModel.Section = .slate(slate)
        snapshot.appendSections([section])

        recommendations.forEach { recommendation in
            snapshot.appendItems(
                [.recommendation(recommendation.objectID)],
                toSection: section
            )
        }

        return snapshot
    }

    private func handle(notification: Notification) throws {
        source.mainContext.refresh(slate, mergeChanges: true)
        var snapshot = buildSnapshot()

        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else {
            self.snapshot = snapshot
            return
        }

        var itemsToReload: [Cell] = []
        // Reload recommendations whose Items or SavedItems have changed
        // e.g.
        // - Item.savedItem was set to nil or a new object
        // - SavedItem was archived
        itemsToReload += (
            updatedObjects.compactMap { $0 as? Item }
            + updatedObjects.compactMap { ($0 as? SavedItem)?.item }
        )
        .compactMap(\.recommendation)
        .map { .recommendation($0.objectID) }

        snapshot.reloadItems(
            Set(itemsToReload).filter { snapshot.indexOfItem($0) != nil }
        )
        self.snapshot = snapshot
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

extension SlateDetailViewModel {
    func clearIsPresentingReaderSettings() {
        selectedReadableViewModel?.clearIsPresentingReaderSettings()
    }

    func clearSelectedItem() {
        selectedReadableViewModel = nil
    }

    func clearSharedActivity() {
        selectedReadableViewModel?.clearSharedActivity()
        sharedActivity = nil
    }

    func clearPresentedWebReaderURL() {
        presentedWebReaderURL = nil
        selectedReadableViewModel?.clearPresentedWebReaderURL()
    }

    func clearRecommendationToReport() {
        selectedRecommendationToReport = nil
        selectedReadableViewModel?.clearSelectedRecommendationToReport()
    }
}
