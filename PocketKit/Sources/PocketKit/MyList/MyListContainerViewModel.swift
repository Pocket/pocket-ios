import Combine

class MyListContainerViewModel {
    enum Selection {
        case myList
        case archive
    }

    @Published
    var selection: Selection = .myList

    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: ArchivedItemsListViewModel

    init(savedItemsList: SavedItemsListViewModel, archivedItemsList: ArchivedItemsListViewModel) {
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
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
