import Combine
import Sync
import UIKit
import SharedPocketKit

class SavesContainerViewModel {
    enum Selection {
        case saves
        case archive
    }

    @Published
    var selection: Selection = .saves

    let networkPathMonitor: NetworkPathMonitor
    let user: User
    let userDefaults: UserDefaults
    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: ArchivedItemsListViewModel

    init(
        networkPathMonitor: NetworkPathMonitor,
        user: User,
        userDefaults: UserDefaults,
        savedItemsList: SavedItemsListViewModel,
        archivedItemsList: ArchivedItemsListViewModel
    ) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
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
