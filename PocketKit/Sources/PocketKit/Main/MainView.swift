//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/8/23.
//

import SwiftUI

public struct MainView: View {
    @ObservedObject var model: MainViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selection = 0

    public var body: some View {
        if horizontalSizeClass == .compact {
            TabView {
                makeHome()
                    .tabItem {
                        selection == 1 ? Image(asset: .tabHomeSelected) : Image(asset: .tabHomeDeselected)
                        Text(L10n.home)
                    }
                    .accessibilityIdentifier("home-tab-bar-button")

                    SavesContainerViewControllerSwiftUI(model: model.saves)

                    .tabItem {
                        selection == 0 ? Image(asset: .tabSavesSelected) : Image(asset: .tabSavesDeselected)
                        Text(L10n.saves)
                    }
                    .accessibilityIdentifier("saves-tab-bar-button")

                NavigationView {
                    SettingsView(model: model.account)
                }
                    .tabItem {
                        selection == 2 ? Image(asset: .tabSettingsSelected) : Image(asset: .tabSettingsDeselected)
                        Text(L10n.settings)
                    }
                    .accessibilityIdentifier("account-tab-bar-button")
            }
            // TODO: match old UITabBar styling.
            .background(Color(.ui.white1))
            .foregroundColor(Color(.ui.grey1))
            .tint(Color(.ui.grey1))
        } else {
            makeHome()
        }
    }

    private func makeHome() -> some View {
        NavigationView {
            HomeViewControllerSwiftUI(model: model.home, savesModel: model.saves)
                .navigationTitle(L10n.home)
                .navigationBarTitleDisplayMode(.large)
                .if(horizontalSizeClass != .compact) { view in
                    view.navigationBarItems(trailing: NavigationLink(
                        destination: SettingsView(model: model.account),
                        label: {
                            Image(asset: .tabSettingsDeselected)
                        }
                    ))
                }
        }
        .navigationViewStyle(.stack)
    }
}
