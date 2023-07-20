// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import UIKit
import SharedPocketKit

@MainActor
class SavesContainerViewModel {
    enum Selection {
        case saves
        case archive
    }

    @Published var selection: Selection = .saves

    let searchList: SearchViewModel
    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: SavedItemsListViewModel
    let addSavedItemModel: AddSavedItemViewModel

    init(
        searchList: SearchViewModel,
        savedItemsList: SavedItemsListViewModel,
        archivedItemsList: SavedItemsListViewModel,
        addSavedItemModel: AddSavedItemViewModel
    ) {
        self.searchList = searchList
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
        self.addSavedItemModel = addSavedItemModel
    }

    var selectedItem: SelectedItem? {
        savedItemsList.selectedItem ?? archivedItemsList.selectedItem
    }

    func activityItemsForSelectedItem(url: URL) -> [UIActivity] {
        let selectedItem = savedItemsList.selectedItem ?? archivedItemsList.selectedItem
        switch selectedItem {
        case .webView(let readableViewModel),
                .readable(let readableViewModel):
            return readableViewModel?.webViewActivityItems(url: url) ?? []
        case .none:
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
