import SwiftUI

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init(model: RootViewModel) {
        self.model = model
        self.setupTabBarAppearance()
    }

    /// Sets up the tab bar appearance following some of https://stackoverflow.com/questions/56969309/change-tabbed-view-bar-color-swiftui
    private func setupTabBarAppearance() {
        let tabBarAppeareance = UITabBarAppearance()
        tabBarAppeareance.configureWithOpaqueBackground()

        tabBarAppeareance.shadowColor = UIColor(.ui.grey1) // For line separator of the tab bar
        tabBarAppeareance.backgroundColor = UIColor(.ui.white1)
        tabBarAppeareance.backgroundEffect = nil
        tabBarAppeareance.selectionIndicatorTintColor = UIColor(.ui.grey1)

        tabBarAppeareance.stackedLayoutAppearance = tabItemAppearance
        tabBarAppeareance.compactInlineLayoutAppearance = tabItemAppearance
        tabBarAppeareance.inlineLayoutAppearance = tabItemAppearance

        // Use this appearance when scrolling behind the TabView:
        UITabBar.appearance().standardAppearance = tabBarAppeareance
        // Use this appearance when scrolled all the way up:
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppeareance
    }

    private var tabItemAppearance: UITabBarItemAppearance {
       let tabItemAppeareance =  UITabBarItemAppearance()
       tabItemAppeareance.selected.iconColor = UIColor(.ui.grey1)
       tabItemAppeareance.selected.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)
       tabItemAppeareance.normal.iconColor = UIColor(.ui.grey1)
       tabItemAppeareance.normal.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)
       return tabItemAppeareance
    }

    public var body: some View {
        if let model = model.mainViewModel {
            mainView(model: model)
        }

        if let model = model.loggedOutViewModel {
            loggedOutView(model: model)
        }
    }

    private func mainView(model: MainViewModel) -> MainView {
        MainView(model: model, bannerPresenter: Services.shared.bannerPresenter)
    }

    private func loggedOutView(model: LoggedOutViewModel) -> LoggedOutViewControllerSwiftUI {
       LoggedOutViewControllerSwiftUI(model: model)
    }
}
