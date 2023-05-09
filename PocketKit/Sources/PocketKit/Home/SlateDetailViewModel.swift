import Foundation
import Sync
import UIKit
import CoreData
import Combine
import Analytics
import SharedPocketKit

class SlateDetailViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot

    @Published var selectedReadableViewModel: RecommendationViewModel?

    @Published var presentedWebReaderURL: URL?

    @Published var selectedRecommendationToReport: Recommendation?

    @Published var sharedActivity: PocketActivity?

    var slateName: String? {
        slate.name
    }

    private let slate: Slate
    private let source: Source
    private let tracker: Tracker
    private let user: User
    private let userDefaults: UserDefaults
    private var subscriptions: [AnyCancellable] = []

    init(slate: Slate, source: Source, tracker: Tracker, user: User, userDefaults: UserDefaults) {
        self.slate = slate
        self.source = source
        self.tracker = tracker
        self.user = user
        self.userDefaults = userDefaults
        self.snapshot = Self.loadingSnapshot()

        NotificationCenter.default.publisher(
            for: NSManagedObjectContext.didSaveObjectsNotification,
            object: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] notification in
            do {
                try self?.handle(notification: notification)
            } catch {
                Log.capture(error: error)
            }
        }.store(in: &subscriptions)
    }

    func trackSlateDetailViewed() {
        guard
            let slateLineup = slate.slateLineup,
            let slateIndex = slateLineup.slates?.index(of: slate)
        else {
            Log.capture(message: "Tried to display slate without slatelineup, not logging analytics")
            return
        }
        tracker.track(event: Events.ExpandedSlate.SlateExpanded(slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: slateIndex, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID))
    }

    func fetch() {
        let snapshot = buildSnapshot()
        guard snapshot.numberOfItems != 0 else { return }
        self.snapshot = snapshot
    }

    func willDisplay(_ cell: SlateDetailViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .recommendation(let objectID):
            guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
                return
            }

            let item = recommendation.item
            guard
                let slate = recommendation.slate,
                let slateLineup = slate.slateLineup
            else {
                Log.capture(message: "Tried to display recommendation without slate and slatelineup, not logging analytics")
                return
            }

            tracker.track(event: Events.ExpandedSlate.SlateArticleImpression(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
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
        guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
            return
        }

        let item = recommendation.item
        var destination: ContentOpen.Destination = .internal
        if item.shouldOpenInWebView {
            let url = pocketPremiumURL(item.bestURL, user: user)
            presentedWebReaderURL = url
            destination = .external
        } else {
            selectedReadableViewModel = RecommendationViewModel(
                recommendation: recommendation,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults
            )
            destination = .internal
        }

        guard
            let slate = recommendation.slate,
            let slateLineup = slate.slateLineup
        else {
            Log.capture(message: "Selected recommendation without an associated slate and slatelineup, not logging analytics")
            return
        }

        tracker.track(event: Events.ExpandedSlate.SlateArticleContentOpen(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID, destination: destination))
    }
}

// MARK: View model and actions
extension SlateDetailViewModel {
    func recommendationViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeRecommendationCellViewModel? {
        guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
            return nil
        }

        guard let indexPath = indexPath else {
            return HomeRecommendationCellViewModel(recommendation: recommendation)
        }

        return HomeRecommendationCellViewModel(
            recommendation: recommendation,
            overflowActions: [
                .share { [weak self] sender in
                    // This view model is used within the context of a view that is presented within Home
                    self?.sharedActivity = PocketItemActivity.fromHome(url: recommendation.item.bestURL, sender: sender)
                },
                .report { [weak self] _ in
                    self?.report(recommendation, at: indexPath)
                }
            ],
            primaryAction: .recommendationPrimary { [weak self] _ in
                let isSaved = recommendation.item.savedItem != nil
                && recommendation.item.savedItem?.isArchived == false

                if isSaved {
                    self?.archive(recommendation, at: indexPath)
                } else {
                    self?.save(recommendation, at: indexPath)
                }
            }
        )
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

        tracker.track(event: Events.ExpandedSlate.SlateArticleSave(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
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

        tracker.track(event: Events.ExpandedSlate.SlateArticleArchive(url: item.givenURL, positionInList: indexPath.item, slateId: slate.remoteID, slateRequestId: slate.requestID, slateExperimentId: slate.experimentID, slateIndex: indexPath.section, slateLineupId: slateLineup.remoteID, slateLineupRequestId: slateLineup.requestID, slateLineupExperimentId: slateLineup.experimentID, recommendationId: recommendation.analyticsID))
    }

    private func report(_ recommendation: Recommendation, at indexPath: IndexPath) {
        selectedRecommendationToReport = recommendation
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
        source.viewRefresh(slate, mergeChanges: true)
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
