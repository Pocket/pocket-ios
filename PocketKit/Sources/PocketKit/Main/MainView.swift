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

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                    .tag(MainViewModel.AppSection.home.id)
                    .accessibilityIdentifier("home-tab-bar-button")
                NavigationView {
                    makeSaves()
                }
                .tabItem {
                    if model.selectedSection == .saves(.saves) || model.selectedSection == .saves(.archive) {
                        Image(asset: .tabSavesSelected)
                    } else {
                        Image(asset: .tabSavesDeselected)
                    }
                    Text(L10n.saves)
                }
                .tag(MainViewModel.AppSection.saves(nil))
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
                .tag(MainViewModel.AppSection.account)
                .accessibilityIdentifier("account-tab-bar-button")
            }
            .background(Color(.ui.white1))
            .foregroundColor(Color(.ui.grey1))
            .tint(Color(.ui.grey1))
    }

    private func makeSaves() -> some View {
        SavesContainerViewControllerSwiftUI(model: model.saves)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    HStack(alignment: .center) {
                        Button(action: {
                            model.selectSavesTab()
                        }) {}
                            .buttonStyle(SavesSelectorButtonStyle(
                                isSelected: Binding<Bool>(
                                    get: {
                                        model.selectedSection == MainViewModel.AppSection.saves(.saves)
                                    },
                                    set: {
                                        if $0 == true {
                                            model.selectSavesTab()
                                        } else {
                                            model.selectArchivesTab()
                                        }
                                    }
                                ),
                                image: Image(asset: .saves),
                                title: L10n.saves
                            )
                            )

                        Button(action: {
                            model.selectArchivesTab()
                        }) {}
                            .buttonStyle(SavesSelectorButtonStyle(
                                isSelected: Binding<Bool>(
                                    get: {
                                        model.selectedSection == MainViewModel.AppSection.saves(.archive)
                                    },
                                    set: {
                                        if $0 == true {
                                            model.selectArchivesTab()
                                        } else {
                                            model.selectSavesTab()
                                        }
                                    }
                                ),
                                image: Image(asset: .archive),
                                title: L10n.archive
                            )
                            )
                    }
                }
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
                                        model.selectAccountTab()
                                    } else {
                                        model.selectHomeTab()
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
                        destination: makeSaves(),
                        isActive: Binding<Bool>(
                            get: {
                                model.selectedSection.id == MainViewModel.AppSection.saves(.saves).id
                            },
                            set: {
                                if $0 == true {
                                    model.selectSavesTab()
                                } else {
                                    model.selectHomeTab()
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
