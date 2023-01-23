import UIKit
import Combine
import SafariServices
import Analytics
import Sync

// swiftlint:disable:next class_delegate_protocol
protocol RegularSavesCoordinatorDelegate: ModalContentPresenting {
    func savesCoordinator(_ coordinator: RegularSavesCoordinator, didSelectSavedItem savedItem: SavedItemViewModel?)
}

class RegularSavesCoordinator: NSObject {
    weak var delegate: RegularSavesCoordinatorDelegate?

    var viewController: UIViewController {
        savesViewController
    }

    private let savesViewController: SavesContainerViewController
    private let model: SavesContainerViewModel
    private var subscriptions: [AnyCancellable] = []
    private var isResetting = false

    init(model: SavesContainerViewModel) {
        self.model = model
        self.savesViewController = SavesContainerViewController(
            searchViewModel: model.searchList,
            viewControllers: [
                ItemsListViewController(model: model.savedItemsList),
                ItemsListViewController(model: model.archivedItemsList)
            ]
        )

        super.init()
    }

    func stopObservingModelChanges() {
        subscriptions = []
    }

    func observeModelChanges() {
        isResetting = true

        model.$selection.sink { [weak self] selection in
            self?.handle(selection)
        }.store(in: &subscriptions)

        // Saves/Saves
        model.savedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope(isFromSaves: true)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedItem.sink { [weak self] selectedSavedItem in
            self?.showSavesItem(selectedSavedItem)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        // Saves/Archive
        model.archivedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope(isFromSaves: false)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$selectedItem.sink { [weak self] selectedArchivedItem in
            self?.showArchivedItem(selectedArchivedItem)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        // Saves/Search
        model.searchList.$selectedItem.sink { [weak self] selectedSavedItem in
            self?.showSavesItem(selectedSavedItem)
        }.store(in: &subscriptions)

        isResetting = false
    }

    private func handle(_ selection: SavesContainerViewModel.Selection?) {
        switch selection {
        case .saves:
            savesViewController.selectedIndex = 0
        case .archive:
            savesViewController.selectedIndex = 1
        default:
            break
        }
    }
}

// MARK: - Showing reader content
extension RegularSavesCoordinator {
    private func showSavesItem(_ selectedSavedItem: SelectedItem?) {
        guard let selectedSavedItem = selectedSavedItem else {
            return
        }

        model.archivedItemsList.clearSelectedItem()
        show(selectedSavedItem)
    }

    private func showArchivedItem(_ selectedArchivedItem: SelectedItem?) {
        guard let selectedArchivedItem = selectedArchivedItem else {
            return
        }

        model.savedItemsList.clearSelectedItem()
        show(selectedArchivedItem)
    }

    private func show(_ selectedItem: SelectedItem) {
        switch selectedItem {
        case .readable(let savedItem):
            delegate?.savesCoordinator(self, didSelectSavedItem: savedItem)
        case .webView(let item):
            guard let url = item?.url else { return }
            present(url)
        }
    }
}

// MARK: - Presenting modals
extension RegularSavesCoordinator {
    private func present(_ url: URL?) {
        delegate?.present(url)
    }

    private func present(_ alert: PocketAlert?) {
        delegate?.present(alert)
    }

    private func present(viewModel: PocketAddTagsViewModel?) {
        delegate?.present(viewModel)
    }

    private func present(_ tagsFilterViewModel: TagsFilterViewModel?) {
        delegate?.present(tagsFilterViewModel)
    }

    private func share(_ activity: PocketActivity?) {
        delegate?.share(activity)
    }

    private func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
        guard !isResetting else {
            return
        }

        guard let sortFilterVM = presentedSortFilterViewModel else {
            if viewController.presentedViewController is SortMenuViewController {
                viewController.dismiss(animated: true)
            }
            return
        }

        let viewController = SortMenuViewController(viewModel: sortFilterVM)
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sortFilterVM.sender as? UIView
        self.viewController.present(viewController, animated: true)
    }

    private func updateSearchScope(isFromSaves: Bool) {
        savesViewController.navigationItem.searchController?.isActive = true
        savesViewController.updateSearchScope()
    }
}

extension RegularSavesCoordinator: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return model.activityItemsForSelectedItem(url: URL)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}
