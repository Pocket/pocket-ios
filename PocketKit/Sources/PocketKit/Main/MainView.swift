// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization
import TipKit
import SharedPocketKit

public struct MainView: View {
    @ObservedObject var model: MainViewModel
    @ObservedObject var bannerPresenter: BannerPresenter

    @State var tabBarHeightOffset: CGFloat = 0

    public var body: some View {
        TabView(selection: $model.selectedSection) {
            HomeViewControllerSwiftUI(model: model.home)
                .edgesIgnoringSafeArea(.all) // Allow Home to use the entire screen, including under the status bar
                .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
                .tabItem {
                    if model.selectedSection == .home {
                        Image(asset: .tabHomeSelected)
                    } else {
                        Image(asset: .tabHomeDeselected)
                    }
                    Text(Localization.home)
                }
                .accessibilityIdentifier("home-tab-bar-button")
                .tag(MainViewModel.AppSection.home)

            SavesContainerViewControllerSwiftUI(model: model.saves)
                .edgesIgnoringSafeArea(.all) // Allow Saves to use the entire screen, including under the status bar
                .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
                .tabItem {
                    if model.selectedSection == .saves {
                        Image(asset: .tabSavesSelected)
                    } else {
                        Image(asset: .tabSavesDeselected)
                    }
                    Text(Localization.Constants.saves)
                }
                .accessibilityIdentifier("saves-tab-bar-button")
                .tag(MainViewModel.AppSection.saves)

            NavigationView {
                SettingsView(model: model.account)
            }
            .navigationViewStyle(.stack)
            .background(Color(.ui.white1))
            .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
            .tabItem {
                if model.selectedSection == .account {
                    Image(asset: .tabSettingsSelected)
                } else {
                    Image(asset: .tabSettingsDeselected)
                }
                Text(Localization.settings)
            }
            .accessibilityIdentifier("account-tab-bar-button")
            .tag(MainViewModel.AppSection.account)
#if DEBUG
            HomeRootView()
                .navigationViewStyle(.stack)
                .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
                .tabItem {
                    if model.selectedSection == .newHome {
                        Image(asset: .tabHomeSelected)
                    } else {
                        Image(asset: .tabHomeDeselected)
                    }
                    Text("SwiftUI Home")
                }
                .tag(MainViewModel.AppSection.newHome)
#endif
        }
        .zIndex(-1)
        .banner(data: bannerPresenter.bannerData, show: $bannerPresenter.shouldPresentBanner, bottomOffset: 49)
        .task {
            // Initialize tips at app start/user login
            if CommandLine.arguments.contains("hideAllTipsForTesting") {
                Tips.hideAllTipsForTesting()
            }
            do {
                try Tips.configure()
            } catch {
                Log.capture(message: "Unable to initialize tips - \(error)")
            }
        }
        // TODO: SWIFTUI - This is used for tab navigation purposes only, will change as we re-architect the app.
        .environmentObject(model)
    }
}
