// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Analytics
import Sync
import SharedPocketKit

/// View model used for List Item to handle actions for a specific item
@MainActor
class PocketItemViewModel: ObservableObject {
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults
    private let index: Int
    private let scope: SearchScope
    private let user: User
    private let store: SubscriptionStore
    private let networkPathMontor: NetworkPathMonitor
    private weak var searchActionDelegate: SearchResultActionDelegate?

    let item: PocketItem

    @Published var isFavorite: Bool

    @Published var presentShareSheet: Bool = false

    /// Determines whether an item should show Archive or Move To Saves
    var isArchived: Bool {
        item.isArchived
    }

    /// Returns whether the underlying `PocketItem` contains any tags.
    /// Used to dynamically generate the tags action title
    var hasTags: Bool {
        item.hasTags
    }

    /// Retrieves view model to present Add Tags view
    var tagsViewModel: PocketAddTagsViewModel? {
        guard let savedItem = fetchSavedItem() else {
            Log.capture(message: "PocketAddTagsViewModel not returned")
            return nil
        }

        let addTagsViewModel = PocketAddTagsViewModel(
            item: savedItem,
            source: source,
            tracker: tracker,
            userDefaults: userDefaults,
            user: user,
            store: store,
            networkPathMonitor: networkPathMontor,
            saveAction: {}
        )
        tracker.track(event: Events.Search.showAddTags(itemUrl: savedItem.url, positionInList: index, scope: scope))
        return addTagsViewModel
    }

    init(item: PocketItem, index: Int, source: Source, tracker: Tracker, userDefaults: UserDefaults, scope: SearchScope, user: User, store: SubscriptionStore, networkPathMonitor: NetworkPathMonitor, searchActionDelegate: SearchResultActionDelegate? = nil) {
        self.item = item
        self.index = index
        self.source = source
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.scope = scope
        self.isFavorite = item.isFavorite
        self.user = user
        self.store = store
        self.networkPathMontor = networkPathMonitor
        self.searchActionDelegate = searchActionDelegate
    }

    /// Triggers action to favorite or unfavorite an item in a list
    func favoriteAction() -> ItemAction {
        if isFavorite {
            return .unfavorite { [weak self] _ in
                guard let self else {
                    Log.capture(message: "Unfavorite action not taken; self is nil")
                    return
                }
                self._unfavorite()
            }
        } else {
            return .favorite { [weak self] _ in
                guard let self else {
                    Log.capture(message: "Favorite action not taken; self is nil")
                    return
                }
                self._favorite()
            }
        }
    }

    private func _favorite() {
        guard let savedItem = fetchSavedItem() else { return }

        // This view model should be reusable, aside from this tracking call. We can refactor this call when we reuse this for other lists.
        tracker.track(event: Events.Search.favoriteItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.favorite(item: savedItem)
        isFavorite = savedItem.isFavorite
    }

    private func _unfavorite() {
        guard let savedItem = fetchSavedItem() else { return }

        tracker.track(event: Events.Search.unfavoriteItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.unfavorite(item: savedItem)
        isFavorite = savedItem.isFavorite
    }

    /// Triggers action to show share sheet for an item in a list
    func shareAction() -> ItemAction {
        return .share { [weak self] sender in self?._share() }
    }

    private func _share() {
        tracker.track(event: Events.Search.shareItem(itemUrl: item.savedItemURL, positionInList: index, scope: scope))
        presentShareSheet = true
    }

    /// Triggers action to delete an item in a list
    func delete() {
        guard let savedItem = fetchSavedItem() else { return }
        tracker.track(event: Events.Search.deleteItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.delete(item: savedItem)
    }

    /// Triggers action to archive an item in a list
    func archive() {
        searchActionDelegate?.archive(item: item)
        guard let savedItem = fetchSavedItem() else { return }
        tracker.track(event: Events.Search.archiveItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.archive(item: savedItem)
    }

    /// Triggers action to move an item from archive to saves in a list
    func moveToSaves() {
        searchActionDelegate?.unarchive(item: item)
        guard let savedItem = fetchSavedItem() else { return }
        tracker.track(event: Events.Search.unarchiveItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.unarchive(item: savedItem)
    }

    /// Track tapping on overflow menu
    func trackOverflowMenu() {
        guard let savedItem = fetchSavedItem() else { return }
        tracker.track(event: Events.Search.overFlowMenu(itemUrl: savedItem.url, positionInList: index, scope: scope))
    }

    /// Fetch a SavedItem or create one in order to use actions related to source
    private func fetchSavedItem() -> SavedItem? {
        guard let savedItem = source.fetchOrCreateSavedItem(
            with: item.savedItemURL,
            and: item.remoteItemParts
        ) else {
            Log.capture(message: "Saved Item not created")
            return nil
        }
        return savedItem
    }
}
