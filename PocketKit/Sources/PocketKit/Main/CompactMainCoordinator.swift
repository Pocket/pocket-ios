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
    private let myList: CompactMyListContainerCoordinator
    private let home: CompactHomeCoordinator
    private let settings: CompactSettingsCoordinator

    private let model: MainViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collapsedSubscription: AnyCancellable?

    init(
        source: Source,
        tracker: Tracker,
        model: MainViewModel
    ) {
        self.model = model

        myList = CompactMyListContainerCoordinator(model: model.myList)
        myList.viewController.tabBarItem.accessibilityIdentifier = "my-list-tab-bar-button"
        myList.viewController.tabBarItem.title = "My List"
        myList.viewController.tabBarItem.image = UIImage(systemName: "list.dash")

        home = CompactHomeCoordinator(source: source, tracker: tracker, model: model.home)
        home.viewController.tabBarItem.accessibilityIdentifier = "home-tab-bar-button"
        home.viewController.tabBarItem.title = "Home"
        home.viewController.tabBarItem.image = UIImage(systemName: "house")

        settings = CompactSettingsCoordinator(model: model.settings)
        settings.viewController.tabBarItem.accessibilityIdentifier = "settings-tab-bar-button"
        settings.viewController.tabBarItem.title = "Settings"
        settings.viewController.tabBarItem.image = UIImage(systemName: "gearshape")

        tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(.ui.white1)
        tabBarController.tabBar.tintColor = UIColor(.ui.grey1)
        tabBarController.viewControllers = [
            home.viewController,
            myList.viewController,
            settings.viewController
        ]

        super.init()

        tabBarController.delegate = self

        collapsedSubscription = model.$isCollapsed.receive(on: DispatchQueue.main).sink { [weak self] isCollapsed in
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
        case .myList:
            tabBarController.selectedViewController = myList.viewController
        case .home:
            tabBarController.selectedViewController = home.viewController
        case .settings:
            tabBarController.selectedViewController = settings.viewController
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
