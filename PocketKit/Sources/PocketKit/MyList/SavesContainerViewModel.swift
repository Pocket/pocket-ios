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

    init(
        searchList: SearchViewModel,
        savedItemsList: SavedItemsListViewModel,
        archivedItemsList: SavedItemsListViewModel
    ) {
        self.searchList = searchList
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
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
