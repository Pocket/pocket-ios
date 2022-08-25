import UIKit
import SwiftUI
import SafariServices
import Analytics
import Sync
import Combine
import Textile


class CompactMainCoordinator: NSObject {
    var viewController: UIViewController {
        tabBarController
    }

    var tabBar: UITabBar? {
        let tabBar = tabBarController.tabBar
        guard !tabBar.isHidden else { return nil }
        return tabBar
    }
    
    private let tabBarController: UITabBarController
    private let myList: CompactMyListContainerCoordinator
    private let home: CompactHomeCoordinator
    private let account: CompactAccountCoordinator

    private let model: MainViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collapsedSubscription: AnyCancellable?

    init(tracker: Tracker, model: MainViewModel) {
        self.model = model

        myList = CompactMyListContainerCoordinator(model: model.myList)
        myList.viewController.tabBarItem.accessibilityIdentifier = "my-list-tab-bar-button"
        myList.viewController.tabBarItem.title = "My List"
        myList.viewController.tabBarItem.image = UIImage(asset: .tabMyListDeselected)
        myList.viewController.tabBarItem.selectedImage = UIImage(asset: .tabMyListSelected)

        home = CompactHomeCoordinator(tracker: tracker, model: model.home)
        home.viewController.tabBarItem.accessibilityIdentifier = "home-tab-bar-button"
        home.viewController.tabBarItem.title = "Home"
        home.viewController.tabBarItem.image = UIImage(asset: .tabHomeDeselected)
        home.viewController.tabBarItem.selectedImage = UIImage(asset: .tabHomeSelected)

        account = CompactAccountCoordinator(model: model.account)
        account.viewController.tabBarItem.accessibilityIdentifier = "account-tab-bar-button"
        account.viewController.tabBarItem.title = "Account"
        account.viewController.tabBarItem.image = UIImage(asset: .tabAccountDeselected)
        account.viewController.tabBarItem.selectedImage = UIImage(asset: .tabAccountSelected)

        tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(.ui.white1)
        tabBarController.tabBar.tintColor = UIColor(.ui.grey1)
        tabBarController.tabBar.unselectedItemTintColor = UIColor(.ui.grey1)
        tabBarController.viewControllers = [
            home.viewController,
            myList.viewController,
            account.viewController
        ]

        super.init()

        tabBarController.delegate = self
        home.delegate = self

        collapsedSubscription = model.$isCollapsed.sink { [weak self] isCollapsed in
            if isCollapsed {
                self?.observeModelChanges()
            } else {
                self?.stopObservingModelChanges()
            }
        }
    }

    func stopObservingModelChanges() {
        subscriptions = []
        myList.stopObservingModelChanges()
        home.stopObservingModelChanges()
    }

    func observeModelChanges() {
        model.$selectedSection.sink { [weak self] section in
            self?.show(section)
        }.store(in: &subscriptions)

        myList.observeModelChanges()
        home.observeModelChanges()
    }

    private func show(_ section: MainViewModel.AppSection) {
        switch section {
        case .myList(let subsection):
            if subsection == .myList {
                model.myList.selection = .myList
            }
            tabBarController.selectedViewController = myList.viewController
        case .home:
            tabBarController.selectedViewController = home.viewController
        case .account:
            tabBarController.selectedViewController = account.viewController
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

    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        guard tabBarController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return tabBarController.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
}

extension CompactMainCoordinator: CompactHomeCoordinatorDelegate {
    func compactHomeCoordinatorDidSelectRecentSaves(_ coordinator: CompactHomeCoordinator) {
        model.selectedSection = .myList(.myList)
    }
}
