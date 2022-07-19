import UIKit
import SwiftUI
import SafariServices
import Analytics
import Sync
import Combine


class RegularMainCoordinator: NSObject {
    var viewController: UIViewController {
        splitController
    }

    private let splitController: UISplitViewController
    private let navigationSidebar: UINavigationController

    private let myList: MyListContainerViewController
    private let home: HomeViewController
    private let account: AccountViewController
    private let readerRoot: UINavigationController

    private let tracker: Tracker
    private let source: Source

    private let model: MainViewModel

    private var longSubscriptions: [AnyCancellable] = []
    private var subscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    init(
        source: Source,
        tracker: Tracker,
        model: MainViewModel
    ) {
        self.source = source
        self.tracker = tracker
        self.model = model

        splitController = UISplitViewController(style: .tripleColumn)
        splitController.displayModeButtonVisibility = .always

        navigationSidebar = UINavigationController(rootViewController: NavigationSidebarViewController(model: model))
        
        myList = MyListContainerViewController(
            viewControllers: [
                ItemsListViewController(model: model.myList.savedItemsList),
                ItemsListViewController(model: model.myList.archivedItemsList)
            ]
        )
        
        home = HomeViewController(
            source: source,
            tracker: tracker.childTracker(hosting: UIContext.home.screen),
            model: model.home
        )

        account = AccountViewController(model: model.account)
        readerRoot = UINavigationController(rootViewController: UIViewController())

        super.init()

        splitController.setViewController(navigationSidebar, for: .primary)
        splitController.setViewController(home, for: .supplementary)
        splitController.setViewController(readerRoot, for: .secondary)
        splitController.view.tintColor = UIColor(.ui.grey1)

        navigationSidebar.navigationBar.prefersLargeTitles = true
        navigationSidebar.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationSidebar.navigationBar.tintColor = UIColor(.ui.grey1)

        myList.navigationController?.navigationBar.prefersLargeTitles = true
        myList.navigationController?.navigationBar.barTintColor = UIColor(.ui.white1)
        myList.navigationController?.navigationBar.tintColor = UIColor(.ui.grey1)

        home.navigationController?.navigationBar.prefersLargeTitles = true
        home.navigationController?.navigationBar.barTintColor = UIColor(.ui.white1)
        home.navigationController?.navigationBar.tintColor = UIColor(.ui.grey1)
        home.navigationController?.delegate = self

        splitController.delegate = self
    }

    func setCompactViewController(_ compact: UIViewController) {
        splitController.setViewController(compact, for: .compact)
    }

    func showInitialView() {
        model.$isCollapsed.receive(on: DispatchQueue.main).sink { [weak self] isCollapsed in
            if !isCollapsed {
                self?.observeModelChanges()
            } else {
                self?.stopObservingModelChanges()
            }
        }.store(in: &longSubscriptions)
    }

    private func observeModelChanges() {
        isResetting = true

        home.navigationController?.popToRootViewController(animated: false)
        myList.navigationController?.popToRootViewController(animated: false)
        readerRoot.viewControllers = []

        model.$selectedSection.receive(on: DispatchQueue.main).sink { [weak self] section in
            self?.show(section)
        }.store(in: &subscriptions)

        // My List - Saved Items
        model.myList.savedItemsList.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.myList.savedItemsList.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)
        
        model.myList.$selection.receive(on: DispatchQueue.main).sink { [weak self] selection in
            switch selection {
            case .myList:
                self?.myList.selectedIndex = 0
            case .archive:
                self?.myList.selectedIndex = 1
            }
        }.store(in: &subscriptions)

        model.myList.savedItemsList.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] selectedSavedItem in
            guard let selectedSavedItem = selectedSavedItem else { return }
            self?.model.myList.archivedItemsList.selectedItem = nil
            self?.navigate(selectedItem: selectedSavedItem)
        }.store(in: &subscriptions)

        // My List - Archived Items
        model.myList.archivedItemsList.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.myList.archivedItemsList.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.myList.archivedItemsList.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.model.myList.savedItemsList.selectedItem = nil
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        // HOME
        model.home.$selectedReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] readable in
            if readable != nil {
                self?.model.home.selectedSlateDetailViewModel?.selectedReadableViewModel = nil
                self?.model.myList.savedItemsList.selectedItem = nil
                self?.model.myList.archivedItemsList.selectedItem = nil
            }

            self?.show(readable)
        }.store(in: &subscriptions)

        model.home.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation) {
                self?.model.home.selectedRecommendationToReport = nil
            }
        }.store(in: &subscriptions)

        model.home.$selectedSlateDetailViewModel.receive(on: DispatchQueue.main).sink { [weak self] slateDetail in
            self?.show(slateDetail)
        }.store(in: &subscriptions)

        model.home.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url)
        }.store(in: &subscriptions)
        
        model.home.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.home.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.home.$tappedSeeAll.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] section in
            switch section {
            case .recentSaves:
                self?.model.selectedSection = .myList(.myList)
            case .slate(let slate):
                self?.model.home.select(slate: slate)
            default:
                return
            }
        }.store(in: &subscriptions)

        isResetting = false
    }
    
    private func navigate(selectedItem: SelectedItem) {
        switch selectedItem {
        case .readable(let readable):
            self.show(readable)
        case .webView(let url):
            self.present(url)
        }
    }

    private func stopObservingModelChanges() {
        subscriptions = []
        readerSubscriptions = []
    }

    private func show(_ section: MainViewModel.AppSection) {
        switch section {
        case .myList(let subsection):
            if subsection == .myList {
                model.selectedSection = .myList(nil)
                model.myList.selection = .myList
            }
            splitController.setViewController(myList, for: .supplementary)
        case .home:
            splitController.setViewController(home, for: .supplementary)
        case .account:
            splitController.setViewController(account, for: .supplementary)
        }

        splitController.show(.supplementary)
    }

    private func show(_ readable: SavedItemViewModel?) {
        guard let readable = readable else {
            return
        }

        readerSubscriptions = []
        model.home.selectedReadableViewModel = nil
        model.home.selectedSlateDetailViewModel?.selectedReadableViewModel = nil

        readable.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url)
        }.store(in: &readerSubscriptions)

        readable.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: readable)
        }.store(in: &readerSubscriptions)

        readable.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &readerSubscriptions)

        readable.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &readerSubscriptions)

        let readableVC = ReadableHostViewController(readableViewModel: readable)
        readerRoot.viewControllers = [readableVC]
        splitController.show(.secondary)
    }

    private func show(_ readable: RecommendationViewModel?) {
        guard let readable = readable else {
            return
        }

        readerSubscriptions = []
        readable.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url)
        }.store(in: &readerSubscriptions)

        readable.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: readable)
        }.store(in: &readerSubscriptions)

        readable.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &readerSubscriptions)

        readable.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &readerSubscriptions)

        readable.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation) {
                readable.selectedRecommendationToReport = nil
            }
        }.store(in: &readerSubscriptions)

        let readableVC = ReadableHostViewController(readableViewModel: readable)
        readerRoot.viewControllers = [readableVC]
        splitController.show(.secondary)
    }

    private func show(_ slate: SlateDetailViewModel?) {
        guard let slate = slate else {
            slateDetailSubscriptions = []
            return
        }

        slate.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation) {
                slate.selectedRecommendationToReport = nil
            }
        }.store(in: &slateDetailSubscriptions)

        slate.$selectedReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] readable in
            if readable != nil {
                self?.model.home.selectedReadableViewModel = nil
                self?.model.myList.savedItemsList.selectedItem = nil
                self?.model.myList.archivedItemsList.selectedItem = nil
            }

            self?.show(readable)
        }.store(in: &slateDetailSubscriptions)

        slate.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        let slateDetailVC = SlateDetailViewController(model: slate)
        home.navigationController?.pushViewController(slateDetailVC, animated: !isResetting)
    }

    private func present(_ alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        splitController.present(UIAlertController(alert), animated: !isResetting)
    }

    private func present(_ url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        splitController.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard !isResetting, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) {
            readable.isPresentingReaderSettings = false
        }

        readerSettingsVC.modalPresentationStyle = .popover
        readerSettingsVC.popoverPresentationController?.barButtonItem = readerRoot
            .topViewController?
            .navigationItem
            .rightBarButtonItems?
            .first

        splitController.present(readerSettingsVC, animated: !isResetting)
    }

    private func share(_ activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.myList.archivedItemsList.sharedActivity = nil
            self?.model.myList.archivedItemsList.selectedItem?.clearSharedActivity()
            self?.model.myList.savedItemsList.sharedActivity = nil
            self?.model.myList.archivedItemsList.sharedActivity = nil
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

    private func report(_ recommendation: Recommendation?, _ completion: @escaping () -> Void) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: tracker.childTracker(hosting: .reportDialog),
            onDismiss: completion
        )

        host.modalPresentationStyle = .formSheet
        splitController.present(host, animated: !isResetting)
    }
}

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
}

extension RegularMainCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.myList.savedItemsList.selectedItem?.clearPresentedWebReaderURL()
        model.myList.archivedItemsList.selectedItem?.clearPresentedWebReaderURL()
        model.home.selectedReadableViewModel?.presentedWebReaderURL = nil
        model.home.selectedSlateDetailViewModel?.selectedReadableViewModel?.presentedWebReaderURL = nil
    }
}

extension RegularMainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === home {
            model.home.selectedSlateDetailViewModel?.resetSlate(keeping: 5)
            model.home.selectedSlateDetailViewModel = nil
        }
    }
}
