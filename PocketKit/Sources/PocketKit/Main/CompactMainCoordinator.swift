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
    private let settingsRoot: SettingsViewController
    private let settings: UINavigationController

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

        let myListContainer = MyListContainerViewController(
            viewControllers: [
                ItemsListViewController(
                    model: SavedItemsListViewModel(
                        source: source,
                        tracker: tracker.childTracker(hosting: .myList.screen),
                        main: model
                    )
                ),
                ItemsListViewController(
                    model: ArchivedItemsListViewModel(source: source, mainViewModel: model)
                )
            ]
        )

        myList = UINavigationController(rootViewController: myListContainer)
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

        settingsRoot = SettingsViewController(model: model.settings)
        settings = UINavigationController(rootViewController: settingsRoot)
        settings.navigationBar.prefersLargeTitles = true
        settings.navigationBar.barTintColor = UIColor(.ui.white1)
        settings.navigationBar.tintColor = UIColor(.ui.grey1)
        settings.tabBarItem.accessibilityIdentifier = "settings-tab-bar-button"
        settings.tabBarItem.title = "Settings"
        settings.tabBarItem.image = UIImage(systemName: "gearshape")

        tabBarController = UITabBarController()
        tabBarController.viewControllers = [home, myList, settings]
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

    func showSettings() {
        tabBarController.selectedViewController = settings
    }

    func show(item: SavedItem, animated: Bool) {
        let viewModel = SavedItemViewModel(item: item, source: source)
        let readableHost = ReadableHostViewController(
            mainViewModel: model,
            readableViewModel: viewModel,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            source: source
        )
        readableHost.delegate = self
        readableHost.hidesBottomBarWhenPushed = true

        myList.pushViewController(readableHost, animated: animated)
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
    
    func showHome(viewModel: ReadableViewModel, animated: Bool) {
        let viewController = ReadableHostViewController(
            mainViewModel: model,
            readableViewModel: viewModel,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            source: source
        )
        
        home.pushViewController(viewController, animated: animated)
    }
    
    func showMyList(viewModel: ReadableViewModel, animated: Bool) {
        let viewController = ReadableHostViewController(
            mainViewModel: model,
            readableViewModel: viewModel,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            source: source
        )
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        
        myList.pushViewController(viewController, animated: animated)
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
            case .settings:
                self.showSettings()
            }
        }.store(in: &subscriptions)

        model.$selectedMyListReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] viewModel in
            guard let viewModel = viewModel else {
                return
            }
            
            self?.showMyList(viewModel: viewModel, animated: !isResetting)
        }.store(in: &subscriptions)
        
        model.$selectedHomeReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] viewModel in
            guard let viewModel = viewModel else {
                return
            }
            
            self?.showHome(viewModel: viewModel, animated: !isResetting)
        }.store(in: &subscriptions)

        model.$selectedSlateID.receive(on: DispatchQueue.main).sink { [weak self] slateID in
            guard let slateID = slateID else {
                return
            }

            self?.showSlate(withID: slateID, animated: !isResetting)
        }.store(in: &subscriptions)

        model.refreshTasks.receive(on: DispatchQueue.main).sink { [weak self] task in
            self?.homeRoot.handleBackgroundRefresh(task: task)
        }.store(in: &subscriptions)

        DispatchQueue.main.async {
            isResetting = false
        }
    }
}

extension CompactMainCoordinator: ReadableHostViewControllerDelegate {
    func readableHostViewControllerDidDeleteItem() {
        popReader()
    }

    func readableHostViewControllerDidArchiveItem() {
        popReader()
    }

    private func popReader() {
        model.selectedMyListReadableViewModel = nil
        myList.popViewController(animated: true)
    }
}

extension CompactMainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        switch navigationController {
        case myList:
            if viewController === myList.viewControllers.first {
                model.selectedMyListReadableViewModel = nil
                return
            }
        case home:
            if viewController === home.viewControllers.first {
                model.selectedSlateID = nil
                model.selectedHomeReadableViewModel = nil
                return
            }

            if viewController is SlateDetailViewController {
                model.selectedHomeReadableViewModel = nil
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
