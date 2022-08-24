import UIKit
import Combine
import SafariServices
import SwiftUI


class CompactMyListContainerCoordinator: NSObject {
    var viewController: UIViewController {
        return navigationController
    }

    private let model: MyListContainerViewModel
    private let navigationController: UINavigationController
    private let containerViewController: MyListContainerViewController
    private var subscriptions: [AnyCancellable]
    private var readableSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    init(model: MyListContainerViewModel) {
        self.model = model
        self.subscriptions = []

        containerViewController = MyListContainerViewController(
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
            case .myList:
                self?.containerViewController.selectedIndex = 0
            case .archive:
                self?.containerViewController.selectedIndex = 1
            }
        }.store(in: &subscriptions)

        // My List navigation
        model.savedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)
        
        model.savedItemsList.$presentAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedItem.sink { [weak self] selectedSavedItem in
            guard let selectedSavedItem = selectedSavedItem else { return }
            self?.navigate(selectedItem: selectedSavedItem)
        }.store(in: &subscriptions)

        // Archive navigation
        model.archivedItemsList.$selectedItem.sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)
        
        isResetting = false
        navigationController.delegate = self
    }
    
    private func navigate(selectedItem: SelectedItem) {
        switch selectedItem {
        case .readable(let readable):
            self.push(savedItem: readable)
        case .webView(let url):
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
        
        readable.$presentAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &readableSubscriptions)

        readable.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.navigationController.popToRootViewController(animated: true)
            }
        }.store(in: &readableSubscriptions)

        navigationController.pushViewController(
            ReadableHostViewController(readableViewModel: readable),
            animated: !isResetting
        )
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        viewController.present(UIAlertController(alert), animated: !isResetting)
    }
    
    private func present(viewModel: AddTagsViewModel?) {
        guard let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        viewController.present(hostingController, animated: true)
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

        // iPhone (Portrait): defaults to .medium(); iPhone (Landscape): defaults to .large()
        // By setting `prefersEdgeAttachedInCompactHeight` and `widthFollowsPreferredContentSizeWhenEdgeAttached`,
        // landscape (iPhone) provides a non-fullscreen view that is dismissable by the user.
        let detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
        readerSettingsVC.sheetPresentationController?.detents = detents
        readerSettingsVC.sheetPresentationController?.prefersGrabberVisible = true
        readerSettingsVC.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
        readerSettingsVC.sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true

        viewController.present(readerSettingsVC, animated: !isResetting)
    }
}

extension CompactMyListContainerCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard viewController === containerViewController else {
            return
        }

        model.clearSelectedItem()
    }
}

extension CompactMyListContainerCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}
