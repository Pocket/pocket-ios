// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import CoreSpotlight
import Sync
import SwiftData

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init(model: RootViewModel) {
        self.model = model
        configureAppearance()
    }

    public var body: some View {
        switch model.viewState {
        case .loggedIn(let mainViewModel):
            mainView(model: mainViewModel)

        case .anonymous(let mainViewModel):
            mainView(model: mainViewModel)

        case .loggedOut(let loggedOutViewModel):
            loggedOutView(model: loggedOutViewModel)

        case .none:
            EmptyView()
        }
    }
}

// MARK: view constructors
private extension RootView {
    func mainView(model: MainViewModel) -> some View {
        MainView(model: model, bannerPresenter: Services.shared.bannerPresenter)
            .onOpenURL { url in
                model.handle(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                guard let url = userActivity.webpageURL else {
                    return
                }
                model.handle(url)
            })
            .onContinueUserActivity(CSSearchableItemActionType, perform: { userActivity in
                model.handleSpotlight(userActivity)
            })
            .modelContainer(Services.shared.dataController)
    }

    func loggedOutView(model: LoggedOutViewModel) -> LoggedOutViewControllerSwiftUI {
        LoggedOutViewControllerSwiftUI(model: model)
    }
}

// MARK: appearance
private extension RootView {
    /// Configure navigation bar and tab bar appearance
    func configureAppearance() {
        configureTabBarAppearance()
        configureNavigationBarAppearance()
    }

    func configureNavigationBarAppearance() {
        let standardAppearance = makeStandardNavigationBarAppearance()
        let largeTitleAppearance = makeLargeTitleNavigationBarAppearance()

        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = largeTitleAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = largeTitleAppearance
    }

    func configureTabBarAppearance() {
        let appearance = makeTabBarAppearance()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    /// Large title navigation bar appearance with blur effect
    func makeLargeTitleNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()

        appearance.backgroundEffect = blurEffect
        appearance.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)
        appearance.backgroundColor = UIColor(.ui.white1)
        appearance.shadowColor = UIColor(.ui.white1)

        return appearance
    }
    /// Standard navigation bar appearance with blur effect
    func makeStandardNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()

        appearance.backgroundEffect = blurEffect
        appearance.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)

        return appearance
    }

    /// Tab bar blur effect
    /// see https://stackoverflow.com/questions/56969309/change-tabbed-view-bar-color-swiftui
    var blurEffect: UIBlurEffect? {
        makeTabBarAppearance().backgroundEffect
    }

    func makeTabBarAppearance() -> UITabBarAppearance {
        let itemAppearance = makeTabItemAppearance()
        let tabBarAppearance = UITabBarAppearance()

        tabBarAppearance.selectionIndicatorTintColor = UIColor(.ui.grey1)
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance

        return tabBarAppearance
    }

    func makeTabItemAppearance() -> UITabBarItemAppearance {
       let tabItemAppeareance =  UITabBarItemAppearance()

       tabItemAppeareance.selected.iconColor = UIColor(.ui.grey1)
       tabItemAppeareance.selected.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)
       tabItemAppeareance.normal.iconColor = UIColor(.ui.grey1)
       tabItemAppeareance.normal.titleTextAttributes[.foregroundColor] = UIColor(.ui.grey1)

       return tabItemAppeareance
    }
}
