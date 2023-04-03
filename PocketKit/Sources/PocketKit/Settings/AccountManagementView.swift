// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization

struct AccountManagementView: View {
    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 16.0, *) {
                AccountManagementForm(model: model)
                    .scrollContentBackground(.hidden)
                    .background(Color(.ui.white1))
            } else {
                AccountManagementForm(model: model)
                    .background(Color(.ui.white1))
            }
        }
        .navigationBarTitle(Localization.Settings.accountManagement, displayMode: .large)
        .accessibilityIdentifier("account-management")
        .onAppear {
            model.trackAccountManagementImpression()
        }
    }
}

struct AccountManagementForm: View {
    @ObservedObject
    var model: AccountViewModel
    var body: some View {
        Form {
            Group {
                Section {
                    if !model.isPremium {
                        SettingsRowButton(title: Localization.Settings.AccountManagement.restoreSubscription, trailingImageAsset: .chevronRight) {
                            model.attemptRestoreSubscription()
                        }
                        // NOTE: SwiftUI does not play well with more than one alert attached to the same view, that's why we have one here
                        // and one attached to the button below...
                        // ref https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-multiple-alerts-in-a-single-view
                        .alert(isPresented: $model.isPresentingRestoreNotSuccessful) {
                            Alert(
                                title: Text(Localization.Settings.AccountManagement.RestoreSubscription.RestoreNotSuccessful.title),
                                message: Text(Localization.Settings.AccountManagement.RestoreSubscription.RestoreNotSuccessful.message),
                                dismissButton: .default(Text(Localization.ok))
                            )
                        }
                        .accessibilityIdentifier("restore-existing-subscription-button")
                    }

                    SettingsRowButton(title: Localization.Settings.AccountManagement.deleteAccount, trailingImageAsset: .chevronRight) {
                        model.trackDeleteTapped()
                        model.isPresentingDeleteYourAccount.toggle()
                    }
                    .alert(isPresented: $model.isPresentingRestoreSuccessful) {
                        Alert(
                            title: Text(Localization.Settings.AccountManagement.RestoreSubscription.RestoreSuccessful.title),
                            message: Text(Localization.Settings.AccountManagement.RestoreSubscription.RestoreSuccessful.message),
                            dismissButton: .default(Text(Localization.ok))
                        )
                    }
                    .sheet(isPresented: $model.isPresentingDeleteYourAccount) {
                        DeleteAccountView(viewModel: model.makeDeleteAccountViewModel())
                    }
                    .accessibilityIdentifier("delete-your-account-button")
                }
                .textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
        }
    }
}
