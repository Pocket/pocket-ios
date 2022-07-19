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
}
