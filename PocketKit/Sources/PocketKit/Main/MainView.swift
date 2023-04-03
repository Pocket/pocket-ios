import SwiftUI
import Textile
import L10n

public struct MainView: View {
    @ObservedObject var model: MainViewModel

    @State var tabBarHeightOffset: CGFloat = 0

    public var body: some View {
        TabView(selection: $model.selectedSection) {
            HomeViewControllerSwiftUI(model: model.home)
                .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
                .tabItem {
                    if model.selectedSection == .home {
                        Image(asset: .tabHomeSelected)
                    } else {
                        Image(asset: .tabHomeDeselected)
                    }
                    Text(L10n.home)
                }
                .accessibilityIdentifier("home-tab-bar-button")
                .tag(MainViewModel.AppSection.home)

            SavesContainerViewControllerSwiftUI(model: model.saves)
                .tabBarHeightOffset { offset in tabBarHeightOffset = offset }
                .tabItem {
                    if model.selectedSection == .saves {
                        Image(asset: .tabSavesSelected)
                    } else {
                        Image(asset: .tabSavesDeselected)
                    }
                    Text(L10n.saves)
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
                Text(L10n.settings)
            }
            .accessibilityIdentifier("account-tab-bar-button")
            .tag(MainViewModel.AppSection.account)
        }
        .overlay(alignment: .bottomLeading, content: {
            if let banner = model.bannerViewModel {
                ZStack(alignment: .bottom) {}
                    .pasteboard(data: banner, show: .constant(true), bottomOffset: tabBarHeightOffset)
            }
        })
        .background(Color(.ui.white1))
        .foregroundColor(Color(.ui.grey1))
        .tint(Color(.ui.grey1))
    }
}
