// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
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
    }
}

struct AccountManagementForm: View {
    @ObservedObject
    var model: AccountViewModel
    var body: some View {
        Form {
            Group {
                Section(header: Text(L10n.yourAccount).style(.settings.header)) {
                    SettingsRowButton(title: L10n.Settings.AccountManagement.deleteAccount, titleStyle: .settings.button.delete, icon: SFIconModel("rectangle.portrait.and.arrow.right", weight: .semibold, color: Color(.ui.apricot1))) {
                        model.isPresentingDeleteYourAccount.toggle()
                    }
                    .accessibilityIdentifier("delete-your-account-button")
                }
                .sheet(isPresented: $model.isPresentingDeleteYourAccount) {
                    DeleteAccountView(model: model)
                }
                .textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
        }
    }
}
