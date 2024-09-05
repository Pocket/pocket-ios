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
class SharedWithYouListViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot
    @Published var selectedReadableViewModel: RecommendableItemViewModel?
    @Published var selectedCollectionViewModel: CollectionViewModel?
    @Published var presentedWebReaderURL: URL?
    @Published var sharedActivity: PocketActivity?

    private let list: [CDSharedWithYouItem]
    private let source: Source
    private let tracker: Tracker
    private let user: User
    private let store: SubscriptionStore
    private let userDefaults: UserDefaults
    private let networkPathMonitor: NetworkPathMonitor
    private var subscriptions: [AnyCancellable] = []
    private let featureFlags: FeatureFlagServiceProtocol
    private let notificationCenter: NotificationCenter
    private let accessService: PocketAccessService

    init(
        list: [CDSharedWithYouItem],
        source: Source,
        tracker: Tracker,
        user: User,
        store: SubscriptionStore,
        userDefaults: UserDefaults,
        networkPathMonitor: NetworkPathMonitor,
        featureFlags: FeatureFlagServiceProtocol,
        notificationCenter: NotificationCenter,
        accessService: PocketAccessService
    ) {
        self.list = list
        self.source = source
        self.tracker = tracker
        self.user = user
        self.store = store
        self.userDefaults = userDefaults
        self.snapshot = Self.loadingSnapshot()
        self.featureFlags = featureFlags
        self.networkPathMonitor = networkPathMonitor
        self.notificationCenter = notificationCenter
        self.accessService = accessService

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
        tracker.track(event: Events.SharedWithYou.screenView())
    }

    func fetch() {
        let snapshot = buildSnapshot()
        guard snapshot.numberOfItems != 0 else { return }
        self.snapshot = snapshot
    }

    func willDisplay(_ cell: SharedWithYouListViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .item(let objectID):
            guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
                return
            }

            tracker.track(event: Events.SharedWithYou.cardImpression(url: sharedWithYouItem.url, index: indexPath.item))
        }
    }
}

// MARK: - Cell Selection
extension SharedWithYouListViewModel {
    func select(cell: SharedWithYouListViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .item(let objectID):
            selectItem(with: objectID, at: indexPath)
        }
    }

    private func selectItem(with objectID: NSManagedObjectID, at indexPath: IndexPath) {
        guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
            return
        }

        let item = sharedWithYouItem.item
        var destination: ContentOpen.Destination = .internal

        if let slug = item.collectionSlug {
            selectedCollectionViewModel = CollectionViewModel(
                slug: slug,
                source: source,
                tracker: tracker,
                user: user,
                store: store,
                networkPathMonitor: networkPathMonitor,
                userDefaults: userDefaults,
                featureFlags: featureFlags,
                notificationCenter: notificationCenter,
                accessService: accessService
            )
        } else if item.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
            guard let bestURL = URL(percentEncoding: item.bestURL) else { return }
            let url = pocketPremiumURL(bestURL, user: user)
            presentedWebReaderURL = url
            destination = .external
        } else {
            selectedReadableViewModel = RecommendableItemViewModel(
                item: sharedWithYouItem.item,
                source: source,
                accessService: accessService,
                tracker: tracker.childTracker(hosting: .articleView.screen),
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults
            )
            destination = .internal
        }
        tracker.track(
            event: Events
                .SharedWithYou
                .contentOpen(
                    url: sharedWithYouItem.url,
                    index: indexPath.item,
                    destination: destination
                )
        )
    }
}

// MARK: View model and actions
extension SharedWithYouListViewModel {
    func cellViewModel(
        for objectID: NSManagedObjectID,
        at indexPath: IndexPath? = nil
    ) -> HomeItemCellViewModel? {
        guard let sharedWithYouItem = source.viewObject(id: objectID) as? CDSharedWithYouItem else {
            return nil
        }

        guard let indexPath = indexPath else {
            return HomeItemCellViewModel(
                item: sharedWithYouItem.item,
                imageURL: sharedWithYouItem.item.topImageURL,
                title: sharedWithYouItem.item.title,
                sharedWithYouUrlString: sharedWithYouItem.url
            )
        }

        return HomeItemCellViewModel(
            item: sharedWithYouItem.item,
            overflowActions: [
                .share { [weak self] sender in
                    // This view model is used within the context of a view that is presented within Home
                    self?.sharedActivity = PocketItemActivity.fromHome(url: sharedWithYouItem.item.bestURL, sender: sender)
                }
            ],
            primaryAction: .sharedWithYouPrimary { [weak self] _ in
                if let savedItem = sharedWithYouItem.item.savedItem, !savedItem.isArchived {
                    self?.archive(savedItem, at: indexPath)
                } else {
                    self?.save(sharedWithYouItem.item, at: indexPath)
                }
            },
            imageURL: sharedWithYouItem.item.topImageURL,
            title: sharedWithYouItem.item.title,
            sharedWithYouUrlString: sharedWithYouItem.url
        )
    }

    private func save(_ item: CDItem, at indexPath: IndexPath) {
        source.save(item: item)
        if let url = item.sharedWithYouItem?.url {
            tracker.track(event: Events.SharedWithYou.itemSaved(url: url, index: indexPath.item))
        }
    }

    private func archive(_ savedItem: CDSavedItem, at indexPath: IndexPath) {
        source.archive(item: savedItem)
        if let url = savedItem.item?.sharedWithYouItem?.url {
            tracker.track(event: Events.SharedWithYou.itemArchived(url: url, index: indexPath.item))
        }
    }
}

private extension SharedWithYouListViewModel {
    static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
    }

    func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let section: SharedWithYouListViewModel.Section = .list(list)
        snapshot.appendSections([section])

        list.forEach { item in
            snapshot.appendItems(
                [.item(item.objectID)],
                toSection: section
            )
        }

        return snapshot
    }

    private func handle(notification: Notification) throws {
        list.forEach {
            source.viewRefresh($0, mergeChanges: true)
        }

        var snapshot = buildSnapshot()

        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else {
            self.snapshot = snapshot
            return
        }

        let itemsToReload: [Cell] = (
            updatedObjects.compactMap { $0 as? CDItem }
            + updatedObjects.compactMap { ($0 as? CDSavedItem)?.item }
        )
        .compactMap(\.sharedWithYouItem)
        .map { .item($0.objectID) }

        snapshot.reloadItems(
            Set(itemsToReload).filter { snapshot.indexOfItem($0) != nil }
        )
        self.snapshot = snapshot
    }
}

extension SharedWithYouListViewModel {
    enum Section: Hashable {
        case loading
        case list([CDSharedWithYouItem])
    }

    enum Cell: Hashable {
        case loading
        case item(NSManagedObjectID)
    }
}

extension SharedWithYouListViewModel {
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
}
