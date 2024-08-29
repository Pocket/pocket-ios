// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import UIKit
import SharedPocketKit
import Analytics

@MainActor
public class SavesContainerViewModel {
    public enum Selection {
        case saves
        case archive
    }

    @Published public var selection: Selection = .saves

    let tracker: Tracker
    let searchList: DefaultSearchViewModel
    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: SavedItemsListViewModel
    let addSavedItemModel: AddSavedItemViewModel
    private let accessService: PocketAccessService

    init(
        tracker: Tracker,
        searchList: DefaultSearchViewModel,
        savedItemsList: SavedItemsListViewModel,
        archivedItemsList: SavedItemsListViewModel,
        addSavedItemModel: AddSavedItemViewModel,
        accessService: PocketAccessService
    ) {
        self.tracker = tracker
        self.searchList = searchList
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
        self.addSavedItemModel = addSavedItemModel
        self.accessService = accessService
    }

    var selectedItem: SelectedItem? {
        savedItemsList.selectedItem ?? archivedItemsList.selectedItem
    }

    var isAnonymous: Bool {
        accessService.accessLevel == .anonymous
    }

    func requestAuthentication() {
        accessService.requestAuthentication(.savesAddUrl)
    }

    func activityItemsForSelectedItem(url: URL) -> [UIActivity] {
        let selectedItem = savedItemsList.selectedItem ?? archivedItemsList.selectedItem
        switch selectedItem {
        case .webView(let readableViewModel),
                .readable(let readableViewModel):
            return readableViewModel?.webViewActivityItems(url: url) ?? []
        case .none:
            return []
        case .some(.collection):
            return []
        }
    }

    func clearSharedActivity() {
        savedItemsList.clearSharedActivity()
        archivedItemsList.clearSharedActivity()
    }

    func clearPresentedWebReaderURL() {
        savedItemsList.clearPresentedWebReaderURL()
        archivedItemsList.clearPresentedWebReaderURL()
    }

    func clearIsPresentingReaderSettings() {
        savedItemsList.clearIsPresentingReaderSettings()
        archivedItemsList.clearIsPresentingReaderSettings()
    }

    func clearSelectedItem() {
        savedItemsList.clearSelectedItem()
        archivedItemsList.clearSelectedItem()
    }
}
