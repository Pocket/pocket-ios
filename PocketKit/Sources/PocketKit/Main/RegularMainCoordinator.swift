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
    private let home: UIViewController
    private let item: ItemViewController

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
            tracker: tracker,
            readerSettings: model.readerSettings
        )
        home.view.backgroundColor = UIColor(.ui.white1)
        
        item = ItemViewController(
            model: model,
            tracker: tracker,
            source: source
        )
        item.view.backgroundColor = UIColor(.ui.white1)

        super.init()

        splitController.setViewController(navigationSidebar, for: .primary)
        splitController.setViewController(myList, for: .supplementary)
        splitController.setViewController(item, for: .secondary)
        
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

        item.navigationController?.navigationBar.prefersLargeTitles = true
        item.navigationController?.navigationBar.barTintColor = UIColor(.ui.white1)
        item.navigationController?.navigationBar.tintColor = UIColor(.ui.grey1)

        item.delegate = self
        splitController.delegate = self

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

    func show(item: Item) {
        splitController.show(.secondary)
    }

    func showSupplementary() {
        guard splitController.traitCollection.horizontalSizeClass == .regular else {
            return
        }

        splitController.show(.supplementary)
    }

    func subscribeToModelChanges() {
        model.$selectedSection.receive(on: DispatchQueue.main).sink { section in
            switch section {
            case .myList:
                self.showMyList()
            case .home:
                self.showHome()
            }
        }.store(in: &subscriptions)

        model.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] item in
            guard let item = item else {
                return
            }

            self?.show(item: item)
        }.store(in: &subscriptions)
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

        let contexts: [SnowplowContext] = [
            Content(url: url),
            UIContext.articleView.screen,
            UIContext.articleView.switchToWebView
        ]

        let engagement = Engagement(type: .general, value: nil)
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

        modal.popoverPresentationController?.barButtonItem = item.popoverAnchor
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
