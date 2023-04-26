import SwiftUI
import Textile
import Localization

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
                        Text(Localization.saves)
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
        }
        .zIndex(-1)
        .banner(data: bannerPresenter.bannerData, show: $bannerPresenter.shouldPresentBanner, bottomOffset: 49)
    }
}
