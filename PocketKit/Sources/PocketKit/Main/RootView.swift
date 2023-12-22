// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import CoreSpotlight

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init(model: RootViewModel) {
        self.model = model
        let blur = self.setupTabBarAppearance()
        self.setupNavBarAppearance(tabBarBlur: blur)
    }

    /// Sets up the nav bar with the given blur effect
    /// - Parameter tabBarBlur: Blur
    private func setupNavBarAppearance(tabBarBlur: UIBlurEffect?) {
        // Nav bar when its the small title
        let navBar = UINavigationBarAppearance()
        navBar.backgroundEffect = tabBarBlur
        navBar.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)

        // Nav Bar when the large title is displayed
        let navBar2 = UINavigationBarAppearance()
        navBar2.backgroundEffect = tabBarBlur
        navBar2.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)
        navBar2.backgroundColor = UIColor(.ui.white1)
        navBar2.shadowColor = UIColor(.ui.white1)

        UINavigationBar.appearance().standardAppearance = navBar
        UINavigationBar.appearance().compactAppearance = navBar
        UINavigationBar.appearance().scrollEdgeAppearance = navBar2
        UINavigationBar.appearance().compactScrollEdgeAppearance = navBar2
    }

    /// Sets up the tab bar appearance following some of https://stackoverflow.com/questions/56969309/change-tabbed-view-bar-color-swiftui
    private func setupTabBarAppearance() -> UIBlurEffect? {
        let tabBarAppeareance = UITabBarAppearance()
        tabBarAppeareance.selectionIndicatorTintColor = UIColor(.ui.grey1)

        tabBarAppeareance.stackedLayoutAppearance = tabItemAppearance
        tabBarAppeareance.compactInlineLayoutAppearance = tabItemAppearance
        tabBarAppeareance.inlineLayoutAppearance = tabItemAppearance

        // Use this appearance when scrolling behind the TabView:
        UITabBar.appearance().standardAppearance = tabBarAppeareance
        // Use this appearance when scrolled all the way up:
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppeareance

        return tabBarAppeareance.backgroundEffect
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
                .onOpenURL { url in
                    model.handle(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                    guard let url = userActivity.webpageURL else {
                        return
                    }
                    model.handle(url)
                })
                // Continues opening an Item that a user tapped on.
                // we could also listen on CSQueryContinuationActionType which will contiunue a search.
                .onContinueUserActivity(CSSearchableItemActionType, perform: { userActivity in
                    guard let coreDataString = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, let coreDataURI = URL(string: coreDataString) else {
                        return
                    }
                    model.handleSpotlight(uri: coreDataURI)
                })
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
