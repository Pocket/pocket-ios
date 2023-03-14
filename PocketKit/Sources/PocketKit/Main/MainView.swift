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

    public var body: some View {
        if horizontalSizeClass == .compact {
            TabView(selection: Binding<String>(
                get: {
                    model.selectedSection.id
                },
                set: {
                    if $0 == MainViewModel.AppSection.saves(.saves).id {
                        model.selectedSection = .saves(.saves)
                    } else if $0 == MainViewModel.AppSection.home.id {
                        model.selectedSection = .home
                    } else if $0 == MainViewModel.AppSection.account.id {
                        model.selectedSection = .account
                    }
                }
            )) {
                makeHome()
                    .tabItem {
                        if model.selectedSection == .home {
                            Image(asset: .tabHomeSelected)
                        } else {
                            Image(asset: .tabHomeDeselected)
                        }
                        Text(L10n.home)
                    }
                    .tag(MainViewModel.AppSection.home.id)
                    .accessibilityIdentifier("home-tab-bar-button")
                NavigationView {
                    SavesContainerViewControllerSwiftUI(model: model.saves)
                        .edgesIgnoringSafeArea(.top)
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                HStack(alignment: .center) {
                                    Button(action: {
                                        model.selectSavesTab()
                                    }) {
                                        Image(asset: .saves)
                                        Text(L10n.saves)
                                    }

                                    Button(action: {
                                        model.selectArchivesTab()
                                    }) {
                                        Image(asset: .archive)
                                        Text(L10n.archive)
                                    }
                                }
                            }
                        }
                }
                .tabItem {
                    if model.selectedSection == .saves(.saves) || model.selectedSection == .saves(.archive) {
                        Image(asset: .tabSavesSelected)
                    } else {
                        Image(asset: .tabSavesDeselected)
                    }
                    Text(L10n.saves)
                }
                .tag(MainViewModel.AppSection.saves(.saves).id)
                .accessibilityIdentifier("saves-tab-bar-button")
                NavigationView {
                    SettingsView(model: model.account)
                }
                .tabItem {
                    if model.selectedSection == .account {
                        Image(asset: .tabSettingsSelected)
                    } else {
                        Image(asset: .tabSettingsDeselected)
                    }
                    Text(L10n.settings)
                }
                .tag(MainViewModel.AppSection.account.id)
                .accessibilityIdentifier("account-tab-bar-button")
            }
            .background(Color(.ui.white1))
            .foregroundColor(Color(.ui.grey1))
            .tint(Color(.ui.grey1))
        } else {
            makeHome()
        }
    }

    private func makeHome() -> some View {
        NavigationView {
            VStack {
                HomeViewControllerSwiftUI(model: model)
                    .navigationTitle(L10n.home)
                    .navigationBarTitleDisplayMode(.large)
                    .if(horizontalSizeClass == .regular) { view in
                        view.navigationBarItems(trailing: NavigationLink(
                            destination: SettingsView(model: model.account),
                            isActive: Binding<Bool>(
                                get: {
                                    model.selectedSection == MainViewModel.AppSection.account
                                },
                                set: {
                                    if $0 == true {
                                        model.selectedSection = MainViewModel.AppSection.account
                                    } else {
                                        model.selectedSection = MainViewModel.AppSection.home
                                    }
                                }
                            ),
                            label: {
                                Image(asset: .tabSettingsDeselected)
                            }
                        ))
                    }

                if horizontalSizeClass == .regular {
                    NavigationLink(
                        destination: SavesContainerViewControllerSwiftUI(model: model.saves),
                        isActive: Binding<Bool>(
                            get: {
                                model.selectedSection.id == MainViewModel.AppSection.saves(.saves).id
                            },
                            set: {
                                if $0 == true {
                                    model.selectedSection = MainViewModel.AppSection.saves(.saves)
                                } else {
                                    model.selectedSection = MainViewModel.AppSection.home
                                }
                            }
                        ),
                        label: { EmptyView() }
                    )
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
