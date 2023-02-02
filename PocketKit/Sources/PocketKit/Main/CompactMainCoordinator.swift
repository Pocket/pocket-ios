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
    private let saves: CompactSavesContainerCoordinator
    private let home: CompactHomeCoordinator
    private let account: CompactAccountCoordinator

    private let model: MainViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collapsedSubscription: AnyCancellable?

    init(tracker: Tracker, model: MainViewModel) {
        self.model = model

        saves = CompactSavesContainerCoordinator(model: model.saves)
        saves.viewController.tabBarItem.accessibilityIdentifier = "saves-tab-bar-button"
        saves.viewController.tabBarItem.title = "Saves".localized()
        saves.viewController.tabBarItem.image = UIImage(asset: .tabSavesDeselected)
        saves.viewController.tabBarItem.selectedImage = UIImage(asset: .tabSavesSelected)

        home = CompactHomeCoordinator(tracker: tracker, model: model.home)
        home.viewController.tabBarItem.accessibilityIdentifier = "home-tab-bar-button"
        home.viewController.tabBarItem.title = "Home".localized()
        home.viewController.tabBarItem.image = UIImage(asset: .tabHomeDeselected)
        home.viewController.tabBarItem.selectedImage = UIImage(asset: .tabHomeSelected)

        account = CompactAccountCoordinator(model: model.account)
        account.viewController.tabBarItem.accessibilityIdentifier = "account-tab-bar-button"
        account.viewController.tabBarItem.title = "Settings".localized()
        account.viewController.tabBarItem.image = UIImage(asset: .tabSettingsDeselected)
        account.viewController.tabBarItem.selectedImage = UIImage(asset: .tabSettingsSelected)

        tabBarController = UITabBarController()
        let appearance = UITabBarAppearance()
        let tabBar = tabBarController.tabBar
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.ui.white1)
        appearance.compactInlineLayoutAppearance.normal.iconColor = UIColor(.ui.grey1)
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.ui.grey1)]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(.ui.grey1)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.ui.grey1)]
        appearance.inlineLayoutAppearance.normal.iconColor = UIColor(.ui.grey1)
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.ui.grey1)]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance

        tabBarController.viewControllers = [
            home.viewController,
            saves.viewController,
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
        saves.stopObservingModelChanges()
        home.stopObservingModelChanges()
    }

    func observeModelChanges() {
        model.$selectedSection.sink { [weak self] section in
            self?.show(section)
        }.store(in: &subscriptions)

        saves.observeModelChanges()
        home.observeModelChanges()
    }

    private func show(_ section: MainViewModel.AppSection) {
        switch section {
        case .saves(let subsection):
            if subsection == .saves {
                model.saves.selection = .saves
            }
            tabBarController.selectedViewController = saves.viewController
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
        model.selectedSection = .saves(.saves)
    }
}
