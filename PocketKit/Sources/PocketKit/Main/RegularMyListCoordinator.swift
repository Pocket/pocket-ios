import UIKit
import Combine
import SafariServices
import Analytics
import Sync

// swiftlint:disable:next class_delegate_protocol
protocol RegularMyListCoordinatorDelegate: ModalContentPresenting {
    func myListCoordinator(_ coordinator: RegularMyListCoordinator, didSelectSavedItem savedItem: SavedItemViewModel?)
}

class RegularMyListCoordinator: NSObject {
    weak var delegate: RegularMyListCoordinatorDelegate?

    var viewController: UIViewController {
        navigationController
    }

    private let myListViewController: MyListContainerViewController
    private let navigationController: UINavigationController
    private let model: MyListContainerViewModel
    private var subscriptions: [AnyCancellable] = []
    private var isResetting = false

    init(model: MyListContainerViewModel) {
        self.model = model
        self.myListViewController = MyListContainerViewController(
            viewControllers: [
                ItemsListViewController(model: model.savedItemsList),
                ItemsListViewController(model: model.archivedItemsList)
            ]
        )
        self.navigationController = UINavigationController(
            rootViewController: myListViewController
        )

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func stopObservingModelChanges() {
        subscriptions = []
    }

    func observeModelChanges() {
        isResetting = true
        navigationController.popToRootViewController(animated: !isResetting)

        model.$selection.sink { [weak self] selection in
            self?.handle(selection)
        }.store(in: &subscriptions)

        // My List/My List
        model.savedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedItem.sink { [weak self] selectedSavedItem in
            self?.showMyListItem(selectedSavedItem)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        // My List/Archive
        model.archivedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$selectedItem.sink { [weak self] selectedArchivedItem in
            self?.showArchivedItem(selectedArchivedItem)
        }.store(in: &subscriptions)

        isResetting = false
    }

    private func handle(_ selection: MyListContainerViewModel.Selection?) {
        switch selection {
        case .myList:
            myListViewController.selectedIndex = 0
        case .archive:
            myListViewController.selectedIndex = 1
        default:
            break
        }
    }
}

// MARK: - Showing reader content
extension RegularMyListCoordinator {
    private func showMyListItem(_ selectedSavedItem: SelectedItem?) {
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
            delegate?.myListCoordinator(self, didSelectSavedItem: savedItem)
        case .webView(let url):
            present(url)
        }
    }
}

// MARK: - Presenting modals
extension RegularMyListCoordinator {
    private func present(_ url: URL?) {
        delegate?.present(url)
    }

    private func present(_ alert: PocketAlert?) {
        delegate?.present(alert)
    }

    private func present(viewModel: AddTagsViewModel?) {
        delegate?.present(viewModel)
    }

    private func share(_ activity: PocketActivity?) {
        delegate?.share(activity)
    }

    private func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
        guard !isResetting else {
            return
        }

        guard let sortFilterVM = presentedSortFilterViewModel else {
            if navigationController.presentedViewController is SortMenuViewController {
                navigationController.dismiss(animated: true)
            }
            return
        }

        let viewController = SortMenuViewController(viewModel: sortFilterVM)
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sortFilterVM.sender as? UIView
        navigationController.present(viewController, animated: true)
    }
}

extension RegularMyListCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}
