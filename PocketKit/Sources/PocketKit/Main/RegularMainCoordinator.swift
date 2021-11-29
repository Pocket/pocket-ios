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
    private let myList: UIViewController
    private let home: HomeViewController
    private let settings: SettingsViewController

    private let readerRoot: UINavigationController
    private let itemVC: ItemViewController
    private let recommendationVC: ArticleViewController

    private let tracker: Tracker
    private let source: Source

    private let model: MainViewModel

    private var subscriptions: [AnyCancellable] = []
    private var longSubscriptions: [AnyCancellable] = []

    init(
        source: Source,
        tracker: Tracker,
        model: MainViewModel
    ) {
        self.source = source
        self.tracker = tracker
        self.model = model

        let listView = ItemListView(model: model)
            .environment(\.managedObjectContext, source.mainContext)
            .environment(\.source, source)
            .environment(\.tracker, tracker)

        splitController = UISplitViewController(style: .tripleColumn)
        splitController.displayModeButtonVisibility = .always
        
        navigationSidebar = UINavigationController(rootViewController: NavigationSidebarViewController(model: model))
        
        myList = UIHostingController(rootView: listView)
        myList.view.backgroundColor = UIColor(.ui.white1)
        
        home = HomeViewController(
            source: source,
            tracker: tracker.childTracker(hosting: UIContext.home.screen),
            model: model
        )
        home.view.backgroundColor = UIColor(.ui.white1)

        settings = SettingsViewController(model: model.settings)
        settings.view.backgroundColor = UIColor(.ui.white1)

        itemVC = ItemViewController(
            model: model,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            source: source
        )
        itemVC.view.backgroundColor = UIColor(.ui.white1)

        recommendationVC = ArticleViewController(
            readerSettings: model.readerSettings,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            viewModel: model
        )

        readerRoot = UINavigationController(rootViewController: itemVC)

        super.init()

        splitController.setViewController(navigationSidebar, for: .primary)
        splitController.setViewController(myList, for: .supplementary)
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

        itemVC.navigationController?.navigationBar.prefersLargeTitles = true
        itemVC.navigationController?.navigationBar.barTintColor = UIColor(.ui.white1)
        itemVC.navigationController?.navigationBar.tintColor = UIColor(.ui.grey1)

        itemVC.delegate = self
        splitController.delegate = self
        home.navigationController?.delegate = self

        model.$isCollapsed.receive(on: DispatchQueue.main).sink { [weak self] isCollapsed in
            if !isCollapsed {
                self?.subscribeToModelChanges()
            } else {
                self?.subscriptions = []
            }
        }.store(in: &longSubscriptions)

        model.$sharedActivity.sink { [weak self] activity in
            self?.share(activity: activity)
        }.store(in: &longSubscriptions)

        model.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            guard isPresenting else {
                return
            }

            self?.presentReaderSettings()
        }.store(in: &longSubscriptions)

        model.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.presentWebReader(url: url)
        }.store(in: &longSubscriptions)
        
        model.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            guard let recommendation = recommendation else {
                return
            }

            self?.report(recommendation: recommendation, animated: true) {
                self?.model.selectedRecommendationToReport = nil
            }
        }.store(in: &longSubscriptions)
    }

    func setCompactViewController(_ compact: UIViewController) {
        splitController.setViewController(compact, for: .compact)
    }

    func showMyList() {
        splitController.setViewController(myList, for: .supplementary)
    }

    func showHome() {
        splitController.setViewController(home, for: .supplementary)
    }

    func showSettings() {
        splitController.setViewController(settings, for: .supplementary)
    }

    func show(item: SavedItem) {
        itemVC.savedItem = item
        readerRoot.viewControllers = [itemVC]

        splitController.show(.secondary)
    }

    func show(recommendation: Slate.Recommendation) {
        recommendationVC.item = recommendation
        readerRoot.viewControllers = [recommendationVC]

        splitController.show(.secondary)
    }
    
    func report(recommendation: Slate.Recommendation, animated: Bool, onDismiss: @escaping () -> Void) {
        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            model: model,
            tracker: tracker.childTracker(hosting: .reportDialog),
            onDismiss: onDismiss
        )
        host.modalPresentationStyle = .formSheet
        splitController.present(host, animated: animated)
    }


    func showSlate(withID slateID: String, animated: Bool) {
        let slateDetail = SlateDetailViewController(
            source: source,
            model: model,
            tracker: tracker.childTracker(hosting: .slateDetail.screen),
            slateID: slateID
        )

        home.navigationController?.pushViewController(slateDetail, animated: animated)
    }

    func showSupplementary() {
        guard splitController.traitCollection.horizontalSizeClass == .regular else {
            return
        }

        splitController.show(.supplementary)
    }

    func subscribeToModelChanges() {
        var isResetting = true
        home.navigationController?.popToRootViewController(animated: false)

        model.$selectedSection.receive(on: DispatchQueue.main).sink { section in
            switch section {
            case .myList:
                self.showMyList()
            case .home:
                self.showHome()
            case .settings:
                self.showSettings()
            }
        }.store(in: &subscriptions)

        model.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] item in
            guard let item = item else {
                return
            }

            self?.show(item: item)
        }.store(in: &subscriptions)

        model.$selectedSlateID.receive(on: DispatchQueue.main).sink { [weak self] slateID in
            guard let slateID = slateID else {
                return
            }

            self?.showSlate(withID: slateID, animated: !isResetting)
        }.store(in: &subscriptions)

        model.$selectedRecommendation.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            guard let recommendation = recommendation else {
                return
            }

            self?.show(recommendation: recommendation)
        }.store(in: &subscriptions)

        model.refreshTasks.receive(on: DispatchQueue.main).sink { [weak self] task in
            self?.home.handleBackgroundRefresh(task: task)
        }.store(in: &subscriptions)

        DispatchQueue.main.async {
            isResetting = false
        }
    }

    func presentReaderSettings() {
        let settings = UIHostingController(rootView: ReaderSettingsView(settings: model.readerSettings))
        showInReaderAsModal(settings)
    }

    func presentWebReader(url: URL?) {
        guard let url = url else {
            return
        }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        splitController.present(safariVC, animated: true)

        let contexts: [Context] = [
            ContentContext(url: url),
            UIContext.articleView.screen,
            UIContext.articleView.switchToWebView
        ]

        let engagement = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: engagement, contexts)
    }

    func share(activity: PocketActivity?) {
        guard let activity = activity else {
            return
        }

        let activityController = UIActivityViewController(activity: activity)
        activityController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.sharedActivity = nil
        }

        showInReaderAsModal(
            activityController,
            detents: [.large()]
        )
    }

    private func showInReaderAsModal(
        _ modal: UIViewController,
        detents: [UISheetPresentationController.Detent] = [.medium()]
    ) {
        if splitController.traitCollection.horizontalSizeClass == .compact {
            modal.modalPresentationStyle = .pageSheet
            modal.sheetPresentationController?.detents = detents
        } else {
            modal.modalPresentationStyle = .popover
        }

        modal.popoverPresentationController?.barButtonItem = itemVC.popoverAnchor
        splitController.present(modal, animated: true)
    }
}

extension RegularMainCoordinator: ItemViewControllerDelegate {
    func itemViewControllerDidDeleteItem(_ itemViewController: ItemViewController) {
        popReader()
    }

    func itemViewControllerDidArchiveItem(_ itemViewController: ItemViewController) {
        popReader()
    }

    private func popReader() {
        model.selectedItem = nil
    }
}

extension RegularMainCoordinator: UISplitViewControllerDelegate {
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        model.isCollapsed = false

        if model.selectedItem == nil {
            splitController.show(.supplementary)
        }
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        model.isCollapsed = true
    }
}

extension RegularMainCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.presentedWebReaderURL = nil
    }
}

extension RegularMainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === home {
            model.selectedSlateID = nil
        }
    }
}
