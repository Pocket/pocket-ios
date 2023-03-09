// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

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
        .navigationBarTitle(L10n.Settings.accountManagement, displayMode: .large)
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
                        SettingsRowButton(title: L10n.Settings.AccountManagement.restoreSubscription, trailingImageAsset: .chevronRight) {
                            model.attemptRestoreSubscription()
                        }
                        // NOTE: SwiftUI does not play well with more than one alert attached to the same view, that's why we have one here
                        // and one attached to the button below...
                        // ref https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-multiple-alerts-in-a-single-view
                        .alert(isPresented: $model.isPresentingRestoreNotSuccessful) {
                            Alert(
                                title: Text(L10n.Settings.AccountManagement.RestoreSubscription.RestoreNotSuccessful.title),
                                message: Text(L10n.Settings.AccountManagement.RestoreSubscription.RestoreNotSuccessful.message),
                                dismissButton: .default(Text(L10n.ok))
                            )
                        }
                        .accessibilityIdentifier("restore-existing-subscription-button")
                    }

                    SettingsRowButton(title: L10n.Settings.AccountManagement.deleteAccount, trailingImageAsset: .chevronRight) {
                        model.trackDeleteTapped()
                        model.isPresentingDeleteYourAccount.toggle()
                    }
                    .alert(isPresented: $model.isPresentingRestoreSuccessful) {
                        Alert(
                            title: Text(L10n.Settings.AccountManagement.RestoreSubscription.RestoreSuccessful.title),
                            message: Text(L10n.Settings.AccountManagement.RestoreSubscription.RestoreSuccessful.message),
                            dismissButton: .default(Text(L10n.ok))
                        )
                    }
                    .sheet(isPresented: $model.isPresentingDeleteYourAccount) {
                        DeleteAccountView(isPremium: model.isPremium, isPresentingCancelationHelp: $model.isPresentingCancelationHelp, hasError: $model.hasError, isDeletingAccount: $model.isDeletingAccount, deleteAccount: model.deleteAccount, helpCancelPremium: model.helpCancelPremium, dismissDelete: { dismiss in model.trackDeleteDismissed(dismissReason: dismiss) }, helpAppeared: model.trackHelpCancelingPremiumImpression ).onAppear {
                            model.trackDeleteConfirmationImpression()
                        }
                    }
                    .accessibilityIdentifier("delete-your-account-button")
                }
                .textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
        }
    }
}
