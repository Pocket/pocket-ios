import Combine

class SavesContainerViewModel {
    enum Selection {
        case saves
        case archive
    }

    @Published
    var selection: Selection = .saves

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
