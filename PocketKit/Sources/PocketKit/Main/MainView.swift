//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/8/23.
//

import SwiftUI
import Textile

public struct MainView: View {
    @ObservedObject var model: MainViewModel
    
    public var body: some View {
        TabView(selection: $model.selectedSection) {
            makeHome()
                .tabItem {
                    if model.selectedSection == .home {
                        Image(asset: .tabHomeSelected)
                    } else {
                        Image(asset: .tabHomeDeselected)
                    }
                    Text(L10n.home)
                }
                .tag(MainViewModel.AppSection.home)
                .accessibilityIdentifier("home-tab-bar-button")
            
            makeSaves()
                .tabItem {
                    if model.selectedSection == .saves {
                        Image(asset: .tabSavesSelected)
                    } else {
                        Image(asset: .tabSavesDeselected)
                    }
                    Text(L10n.saves)
                }
                .tag(MainViewModel.AppSection.saves)
                .accessibilityIdentifier("saves-tab-bar-button")
            makeSettings()
            
                .tabItem {
                    if model.selectedSection == .account {
                        Image(asset: .tabSettingsSelected)
                    } else {
                        Image(asset: .tabSettingsDeselected)
                    }
                    Text(L10n.settings)
                }
                .tag(MainViewModel.AppSection.account)
                .accessibilityIdentifier("account-tab-bar-button")
        }
        .background(Color(.ui.white1))
        .foregroundColor(Color(.ui.grey1))
        .tint(Color(.ui.grey1))
    }
    
    private func makeSettings() -> some View {
        NavigationView {
            SettingsView(model: model.account)
        }
        .navigationViewStyle(.stack)
    }
    
    private func makeSaves() -> some View {
        NavigationView {
            SavesContainerViewControllerSwiftUI(model: model.saves)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .principal) {
                        HStack(alignment: .center) {
                            Button(action: {
                            }) {}
                                .buttonStyle(
                                    SavesSelectorButtonStyle(
                                        isSelected: .constant(false),
                                        image: Image(asset: .saves),
                                        title: L10n.saves
                                    )
                                )
                            
                            Button(action: {
                            }) {}
                                .buttonStyle(
                                    SavesSelectorButtonStyle(
                                        isSelected: .constant(false),
                                        image: Image(asset: .archive),
                                        title: L10n.archive
                                    )
                                )
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private func makeHome() -> some View {
        NavigationView {
            VStack {
                HomeViewControllerSwiftUI(model: model)
                    .navigationTitle(L10n.home)
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .navigationViewStyle(.stack)
    }
}
