class MyListContainerViewModel {
    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: ArchivedItemsListViewModel

    init(savedItemsList: SavedItemsListViewModel, archivedItemsList: ArchivedItemsListViewModel) {
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
    }
}
