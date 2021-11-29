import UIKit
import SwiftUI
import SafariServices
import Analytics
import Sync
import Combine


class CompactMainCoordinator: NSObject {
    var viewController: UIViewController {
        tabBarController
    }

    private let tabBarController: UITabBarController
    private let myList: UINavigationController
    private let homeRoot: HomeViewController
    private let home: UINavigationController

    private let tracker: Tracker
    private let source: Source
    private let model: MainViewModel

    private var subscriptions: [AnyCancellable] = []
    private var collapsedSubscription: AnyCancellable?

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

        let listHost = UIHostingController(rootView: listView)
        listHost.view.backgroundColor = UIColor(.ui.white1)
        myList = UINavigationController(rootViewController: listHost)
        myList.navigationBar.prefersLargeTitles = true
        myList.navigationBar.barTintColor = UIColor(.ui.white1)
        myList.navigationBar.tintColor = UIColor(.ui.grey1)
        myList.tabBarItem.accessibilityIdentifier = "my-list-tab-bar-button"
        myList.tabBarItem.title = "My List"
        myList.tabBarItem.image = UIImage(systemName: "list.dash")

        homeRoot = HomeViewController(
            source: source,
            tracker: tracker.childTracker(hosting: UIContext.home.screen),
            model: model
        )
        homeRoot.view.backgroundColor = UIColor(.ui.white1)
        home = UINavigationController(rootViewController:homeRoot)
        home.navigationBar.prefersLargeTitles = true
        home.navigationBar.barTintColor = UIColor(.ui.white1)
        home.navigationBar.tintColor = UIColor(.ui.grey1)
        home.tabBarItem.accessibilityIdentifier = "home-tab-bar-button"
        home.tabBarItem.title = "Home"
        home.tabBarItem.image = UIImage(systemName: "house")

        tabBarController = UITabBarController()
        tabBarController.viewControllers = [home, myList]
        tabBarController.tabBar.barTintColor = UIColor(.ui.white1)
        tabBarController.tabBar.tintColor = UIColor(.ui.grey1)

        super.init()

        tabBarController.delegate = self
        myList.delegate = self
        home.delegate = self

        collapsedSubscription = model.$isCollapsed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCollapsed in
                if isCollapsed {
                    self?.subscribeToModelChanges()
                } else {
                    self?.subscriptions = []
                }
        }
    }

    func showMyList() {
        tabBarController.selectedViewController = myList
    }

    func showHome() {
        tabBarController.selectedViewController = home
    }

    func show(item: SavedItem, animated: Bool) {
        let itemVC = ItemViewController(
            model: model,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            source: source
        )
        itemVC.savedItem = item
        itemVC.delegate = self
        itemVC.hidesBottomBarWhenPushed = true

        myList.pushViewController(itemVC, animated: animated)
    }

    func show(recommendation: Slate.Recommendation, animated: Bool) {
        let article = ArticleViewController(
            readerSettings: model.readerSettings,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            viewModel: model
        )
        article.hidesBottomBarWhenPushed = true
        article.item = recommendation

        home.pushViewController(article, animated: animated)
    }

    func showSlate(withID slateID: String, animated: Bool) {
        let slateDetail = SlateDetailViewController(
            source: source,
            model: model,
            tracker: tracker.childTracker(hosting: .slateDetail.screen),
            slateID: slateID
        )

        home.pushViewController(slateDetail, animated: animated)
    }

    func subscribeToModelChanges() {
        var isResetting = true
        myList.popToRootViewController(animated: false)
        home.popToRootViewController(animated: false)

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

            self?.show(item: item, animated: !isResetting)
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

            self?.show(recommendation: recommendation, animated: !isResetting)
        }.store(in: &subscriptions)

        model.refreshTasks.receive(on: DispatchQueue.main).sink { [weak self] task in
            self?.homeRoot.handleBackgroundRefresh(task: task)
        }.store(in: &subscriptions)

        DispatchQueue.main.async {
            isResetting = false
        }
    }
}

extension CompactMainCoordinator: ItemViewControllerDelegate {
    func itemViewControllerDidDeleteItem(_ itemViewController: ItemViewController) {
        popReader()
    }

    func itemViewControllerDidArchiveItem(_ itemViewController: ItemViewController) {
        popReader()
    }

    private func popReader() {
        model.selectedItem = nil
        myList.popViewController(animated: true)
    }
}

extension CompactMainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        switch navigationController {
        case myList:
            if viewController === myList.viewControllers.first {
                model.selectedItem = nil
                return
            }
        case home:
            if viewController === home.viewControllers.first {
                model.selectedSlateID = nil
                model.selectedRecommendation = nil
                return
            }

            if viewController is SlateDetailViewController {
                model.selectedRecommendation = nil
                return
            }
        default:
            break
        }
    }
}

extension CompactMainCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return
        }

        model.selectedSection = MainViewModel.AppSection.allCases[index]
    }
}
