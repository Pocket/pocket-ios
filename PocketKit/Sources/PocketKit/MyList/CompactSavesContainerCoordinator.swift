import UIKit
import Combine
import SafariServices
import SwiftUI
import Textile

class CompactSavesContainerCoordinator: NSObject {
    var viewController: UIViewController {
        return navigationController
    }

    private let model: SavesContainerViewModel
    private let navigationController: UINavigationController
    private let containerViewController: SavesContainerViewController
    private var subscriptions: [AnyCancellable]
    private var readableSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    init(model: SavesContainerViewModel) {
        self.model = model
        self.subscriptions = []

        containerViewController = SavesContainerViewController(
            searchViewModel: model.searchList,
            viewControllers: [
                ItemsListViewController(model: model.savedItemsList),
                ItemsListViewController(model: model.archivedItemsList)
            ]
        )
        navigationController = UINavigationController(rootViewController: containerViewController)

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func stopObservingModelChanges() {
        subscriptions = []
        readableSubscriptions = []
    }

    func observeModelChanges() {
        isResetting = true

        navigationController.popToRootViewController(animated: false)

        model.$selection.sink { [weak self] selection in
            switch selection {
            case .saves:
                self?.containerViewController.selectedIndex = 0
            case .archive:
                self?.containerViewController.selectedIndex = 1
            }
        }.store(in: &subscriptions)

        // Saves navigation
        model.savedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope()
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel: tagsFilterViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedItem.sink { [weak self] selectedSavedItem in
            guard let selectedSavedItem = selectedSavedItem else { return }
            self?.navigate(selectedItem: selectedSavedItem)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        // Archive navigation
        model.archivedItemsList.$selectedItem.sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope()
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel: tagsFilterViewModel)
        }.store(in: &subscriptions)

        // Search navigation
        model.searchList.$selectedItem.sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        isResetting = false
        navigationController.delegate = self
    }

    private func navigate(selectedItem: SelectedItem) {
        switch selectedItem {
        case .readable(let readable):
            self.push(savedItem: readable)
        case .webView(let readable):
            readable?.$presentedAlert.sink { [weak self] alert in
                self?.present(alert: alert)
            }.store(in: &readableSubscriptions)

            readable?.events.sink { [weak self] event in
                switch event {
                case .contentUpdated:
                    break
                case .archive, .delete:
                    self?.popToPreviousScreen(navigationController: self?.navigationController)
                }
            }.store(in: &readableSubscriptions)

            guard let url = readable?.url else { return }
            self.present(url: url)
        }
    }

    private func push(savedItem: SavedItemViewModel?) {
        guard let readable = savedItem else {
            readableSubscriptions = []
            return
        }

        readable.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readableSubscriptions)

        readable.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readableSubscriptions)

        readable.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readableSubscriptions)

        readable.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: readable)
        }.store(in: &readableSubscriptions)

        readable.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &readableSubscriptions)

        readable.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen(navigationController: self?.navigationController)
            }
        }.store(in: &readableSubscriptions)

        navigationController.pushViewController(
            ReadableHostViewController(readableViewModel: readable),
            animated: !isResetting
        )
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        guard let presentedVC = viewController.presentedViewController else {
            viewController.present(UIAlertController(alert), animated: !isResetting)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: !isResetting)
    }

    private func present(viewModel: PocketAddTagsViewModel?) {
        guard !isResetting, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        viewController.present(hostingController, animated: !isResetting)
    }

    private func present(tagsFilterViewModel: TagsFilterViewModel?) {
        guard !isResetting, let tagsFilterViewModel = tagsFilterViewModel else { return }
        let hostingController = UIHostingController(rootView: TagsFilterView(viewModel: tagsFilterViewModel))
        hostingController.configurePocketDefaultDetents()
        viewController.present(hostingController, animated: !isResetting)
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)
        // Prevent a crash if you switch from compact to regular while sharing
        activityVC.popoverPresentationController?.sourceView = navigationController.splitViewController?.view

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.clearSharedActivity()
        }

        viewController.present(activityVC, animated: !isResetting)
    }

    private func present(url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        viewController.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard !isResetting, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.model.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
        viewController.present(readerSettingsVC, animated: !isResetting)
    }

    private func updateSearchScope() {
        containerViewController.navigationItem.searchController?.isActive = true
        containerViewController.updateSearchScope()
    }

    func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
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
        viewController.configurePocketDefaultDetents()
        navigationController.present(viewController, animated: true)
    }

    private func popToPreviousScreen(navigationController: UINavigationController?) {
        guard let navController = navigationController else {
            return
        }

        if let presentedVC = navController.presentedViewController {
            presentedVC.dismiss(animated: true) {
                navController.popToRootViewController(animated: true)
            }
        } else {
            navController.popViewController(animated: true)
        }
    }
}

extension CompactSavesContainerCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard viewController === containerViewController else {
            return
        }

        model.clearSelectedItem()

        // By default, when pushing the reader, switching to landscape, and popping,
        // the list will remain in landscape despite only supporting portrait.
        // We have to programatically force the device orientation back to portrait,
        // if the view controller we want to show _only_ supports portrait
        // (e.g when popping from the reader).
        if viewController.supportedInterfaceOrientations == .portrait, UIDevice.current.orientation.isLandscape {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
}

extension CompactSavesContainerCoordinator: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return model.activityItemsForSelectedItem(url: URL)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}
