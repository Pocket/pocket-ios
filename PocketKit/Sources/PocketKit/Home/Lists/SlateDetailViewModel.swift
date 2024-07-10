// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import UIKit
import CoreData
import Combine
import Analytics
import SharedPocketKit

@MainActor
class SlateDetailViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot

    @Published var selectedReadableViewModel: RecommendableItemViewModel?

    @Published var selectedCollectionViewModel: CollectionViewModel?

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
    private let store: SubscriptionStore
    private let userDefaults: UserDefaults
    private let networkPathMonitor: NetworkPathMonitor
    private var subscriptions: [AnyCancellable] = []
    private let featureFlags: FeatureFlagServiceProtocol
    private let notificationCenter: NotificationCenter

    init(slate: Slate, source: Source, tracker: Tracker, user: User, store: SubscriptionStore, userDefaults: UserDefaults, networkPathMonitor: NetworkPathMonitor, featureFlags: FeatureFlagServiceProtocol, notificationCenter: NotificationCenter) {
        self.slate = slate
        self.source = source
        self.tracker = tracker
        self.user = user
        self.store = store
        self.userDefaults = userDefaults
        self.snapshot = Self.loadingSnapshot()
        self.featureFlags = featureFlags
        self.networkPathMonitor = networkPathMonitor
        self.notificationCenter = notificationCenter

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

            let givenURL = item.givenURL
            tracker.track(event: Events.ExpandedSlate.SlateArticleImpression(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
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

        if let slug = recommendation.collection?.slug ?? recommendation.item.collectionSlug {
            selectedCollectionViewModel = CollectionViewModel(slug: slug, source: source, tracker: tracker, user: user, store: store, networkPathMonitor: networkPathMonitor, userDefaults: userDefaults, featureFlags: featureFlags, notificationCenter: notificationCenter)
        } else if item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
            guard let bestURL = URL(percentEncoding: item.bestURL) else { return }
            let url = pocketPremiumURL(bestURL, user: user)
            presentedWebReaderURL = url
            destination = .external
        } else {
            selectedReadableViewModel = RecommendableItemViewModel(
                item: recommendation.item,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults
            )
            destination = .internal
        }

        guard let slate = recommendation.slate else {
            Log.capture(message: "Selected recommendation without an associated slate and slatelineup, not logging analytics")
            return
        }

        let givenURL = item.givenURL
        tracker.track(event: Events.ExpandedSlate.SlateArticleContentOpen(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID, destination: destination))
    }
}

// MARK: View model and actions
extension SlateDetailViewModel {
    func recommendationViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeItemCellViewModel? {
        guard let recommendation = source.viewObject(id: objectID) as? Recommendation else {
            return nil
        }

        guard let indexPath = indexPath else {
            return HomeItemCellViewModel(
                item: recommendation.item,
                imageURL: recommendation.bestImageURL,
                title: recommendation.title
            )
        }

        return HomeItemCellViewModel(
            item: recommendation.item,
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
            },
            imageURL: recommendation.bestImageURL,
            title: recommendation.title
        )
    }

    private func save(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.save(recommendation: recommendation)
        let givenURL =  recommendation.item.givenURL
        tracker.track(event: Events.ExpandedSlate.SlateArticleSave(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
    }

    private func archive(_ recommendation: Recommendation, at indexPath: IndexPath) {
        source.archive(recommendation: recommendation)
        let givenURL = recommendation.item.givenURL
        tracker.track(event: Events.ExpandedSlate.SlateArticleArchive(url: givenURL, positionInList: indexPath.item, recommendationId: recommendation.analyticsID))
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
