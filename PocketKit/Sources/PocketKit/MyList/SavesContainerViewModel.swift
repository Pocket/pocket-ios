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

    @Published
    var selection: Selection = .saves

    private var subscriptions: [AnyCancellable] = []

    var mainViewStore: MainViewStore
    let searchList: SearchViewModel
    let savedItemsList: SavedItemsListViewModel
    let archivedItemsList: SavedItemsListViewModel

    init(
        searchList: SearchViewModel,
        savedItemsList: SavedItemsListViewModel,
        archivedItemsList: SavedItemsListViewModel,
        mainViewStore: MainViewStore
    ) {
        self.searchList = searchList
        self.savedItemsList = savedItemsList
        self.archivedItemsList = archivedItemsList
        self.mainViewStore = mainViewStore

        mainViewStore
            .mainSelectionPublisher
            .receive(on: DispatchQueue.main).sink { [weak self] value in
                guard let self else {
                    Log.capture(message: "No strong self in publisher for saves container from main view")
                    return
                }
                if value == MainViewModel.AppSection.saves(.saves) {
                    self.selection = .saves
                } else if value == MainViewModel.AppSection.saves(.archive) {
                    self.selection = .archive
                }
            }.store(in: &subscriptions)
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
