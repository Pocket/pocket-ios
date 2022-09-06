import UIKit
import SwiftUI
import SafariServices
import Analytics
import Sync
import Combine

protocol ModalContentPresenting: AnyObject {
    func report(_ recommendation: Recommendation?)
    func present(_ url: URL?)
    func present(_ alert: PocketAlert?)
    func present(_ viewModel: AddTagsViewModel?)
    func present(_ readerSettings: ReaderSettings?, isPresenting: Bool?)
    func share(_ activity: PocketActivity?)
}

class RegularMainCoordinator: NSObject {
    var viewController: UIViewController {
        splitController
    }

    private let splitController: UISplitViewController
    private let navigationSidebar: UINavigationController

    private let myList: RegularMyListCoordinator
    private let home: RegularHomeCoordinator
    private let account: AccountViewController
    private let readerRoot: UINavigationController

    private let tracker: Tracker
    private let model: MainViewModel

    private var sizeClassObserver: AnyCancellable?
    private var subscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    init(
        tracker: Tracker,
        model: MainViewModel
    ) {
        self.tracker = tracker
        self.model = model

        splitController = UISplitViewController(style: .doubleColumn)
        splitController.displayModeButtonVisibility = .always

        navigationSidebar = UINavigationController(rootViewController: NavigationSidebarViewController(model: model))

        myList = RegularMyListCoordinator(model: model.myList)
        home = RegularHomeCoordinator(model: model.home, tracker: tracker)
        account = AccountViewController(model: model.account)
        readerRoot = UINavigationController(rootViewController: UIViewController())

        super.init()

        splitController.setViewController(navigationSidebar, for: .primary)
        splitController.setViewController(home.viewController, for: .secondary)
        splitController.view.tintColor = UIColor(.ui.grey1)

        navigationSidebar.navigationBar.prefersLargeTitles = true
        navigationSidebar.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationSidebar.navigationBar.tintColor = UIColor(.ui.grey1)

        myList.delegate = self
        home.delegate = self
        navigationSidebar.delegate = self
        splitController.delegate = self
    }

    func setCompactViewController(_ compact: UIViewController) {
        splitController.setViewController(compact, for: .compact)
    }

    func showInitialView() {
        sizeClassObserver = model.$isCollapsed.sink { [weak self] isCollapsed in
            if !isCollapsed {
                self?.observeModelChanges()
            } else {
                self?.stopObservingModelChanges()
            }
        }
    }

    private func observeModelChanges() {
        isResetting = true
        readerRoot.viewControllers = []
        navigationSidebar.popToRootViewController(animated: !isResetting)

        model.$selectedSection.sink { [weak self] section in
            self?.show(section)
        }.store(in: &subscriptions)

        home.observeModelChanges()
        myList.observeModelChanges()

        isResetting = false
    }

    private func stopObservingModelChanges() {
        subscriptions = []
        readerSubscriptions = []

        home.stopObservingModelChanges()
        myList.stopObservingModelChanges()
    }

    private func show(_ section: MainViewModel.AppSection) {
        switch section {
        case .myList(let subsection):
            if subsection == .myList {
                model.myList.selection = .myList
            }
            navigationSidebar.pushViewController(myList.viewController, animated: true)
        case .home:
            splitController.setViewController(home.viewController, for: .secondary)
        case .account:
            navigationSidebar.pushViewController(account, animated: true)
        }

        splitController.show(.supplementary)
    }
}

// MARK: - Display reader content
extension RegularMainCoordinator {
    private func show(_ readable: SavedItemViewModel?) {
        guard let readable = readable else {
            return
        }
        readerSubscriptions = []

        readable.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url)
        }.store(in: &readerSubscriptions)

        readable.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.present(readable.readerSettings, isPresenting: isPresenting)
        }.store(in: &readerSubscriptions)

        readable.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &readerSubscriptions)

        readable.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(addTagsViewModel)
        }.store(in: &readerSubscriptions)

        readable.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &readerSubscriptions)

        let readableVC = ReadableHostViewController(readableViewModel: readable)
        readerRoot.viewControllers = [readableVC]
        splitController.setViewController(readerRoot, for: .secondary)
    }
}

// MARK: - ModalContentPresenting
extension RegularMainCoordinator: ModalContentPresenting {
    func report(_ recommendation: Recommendation?) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: tracker.childTracker(hosting: .reportDialog),
            onDismiss: { [weak self] in self?.model.clearRecommendationToReport() }
        )

        host.modalPresentationStyle = .formSheet
        splitController.present(host, animated: !isResetting)
    }

    func share(_ activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.clearSharedActivity()
        }

        if let view = activity.sender as? UIView {
            activityVC.popoverPresentationController?.sourceView = view
        } else if let buttonItem = activity.sender as? UIBarButtonItem {
            activityVC.popoverPresentationController?.barButtonItem = buttonItem
        } else {
            activityVC.popoverPresentationController?.barButtonItem = readerRoot
                .topViewController?
                .navigationItem
                .rightBarButtonItems?
                .first
        }

        splitController.present(activityVC, animated: !isResetting)
    }

    func present(_ alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        splitController.present(UIAlertController(alert), animated: !isResetting)
    }

    func present(_ url: URL?) {
        guard let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        readerRoot.isNavigationBarHidden = true
        readerRoot.viewControllers = [safariVC]
        splitController.setViewController(readerRoot, for: .secondary)
    }

    func present(_ viewModel: AddTagsViewModel?) {
        guard !isResetting, let viewModel = viewModel else { return }

        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        splitController.present(hostingController, animated: true)
    }

    func present(_ readerSettings: ReaderSettings?, isPresenting: Bool?) {
        guard !isResetting, let readerSettings = readerSettings, isPresenting == true else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(
            settings: readerSettings,
            onDismiss: { [weak self] in
                self?.model.clearIsPresentingReaderSettings()
            }
        )

        readerSettingsVC.modalPresentationStyle = .popover
        readerSettingsVC.popoverPresentationController?.barButtonItem = readerRoot
            .topViewController?
            .navigationItem
            .rightBarButtonItems?
            .first

        splitController.present(readerSettingsVC, animated: !isResetting)
    }
}

// MARK: - RegularHomeCoordinatorDelegate
extension RegularMainCoordinator: RegularHomeCoordinatorDelegate {
    func homeCoordinatorDidSelectMyList(_ coordinator: RegularHomeCoordinator) {
        model.selectedSection = .myList(.myList)
    }
}

// MARK: - RegularMyListCoordinatorDelegate
extension RegularMainCoordinator: RegularMyListCoordinatorDelegate {
    func myListCoordinator(_ coordinator: RegularMyListCoordinator, didSelectSavedItem savedItem: SavedItemViewModel?) {
        if savedItem != nil {
            model.home.clearSelectedItem()
        }

        show(savedItem)
    }
}

// MARK: - UISplitViewControllerDelegate
extension RegularMainCoordinator: UISplitViewControllerDelegate {
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        if model.isCollapsed {
            model.isCollapsed = false
        }
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        if !model.isCollapsed {
            model.isCollapsed = true
        }
    }

    func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
        guard splitViewController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return splitViewController.viewController(for: .compact)?.supportedInterfaceOrientations ?? .portrait
    }
}

// MARK: - SFSafariViewControllerDelegate
extension RegularMainCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        splitController.setViewController(home.viewController, for: .secondary)
        readerRoot.isNavigationBarHidden = false

        model.clearPresentedWebReaderURL()
    }
}

// MARK: UINavigationControllerDelegate
extension RegularMainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self.navigationSidebar.viewControllers[0] {
            navigationController.isNavigationBarHidden = true
        } else {
            navigationController.isNavigationBarHidden = false
        }
    }
}
