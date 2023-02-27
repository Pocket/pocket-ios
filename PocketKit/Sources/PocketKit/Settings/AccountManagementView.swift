// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Textile

struct AccountManagementView: View {
//    @ObservedObject
//    var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 16.0, *) {
                AccountManagementForm()
                    .scrollContentBackground(.hidden)
                    .background(Color(.ui.white1))
            } else {
                AccountManagementForm()
                    .background(Color(.ui.white1))
            }
        }
        .navigationBarTitle(L10n.settings, displayMode: .large)
        .accessibilityIdentifier("account")
    }
}

struct AccountManagementForm: View {
//    @ObservedObject
//    var model: AccountViewModel
    var body: some View {
        Form {
            Group {
                Section(header: Text(L10n.yourAccount).style(.settings.header)) {
                    SettingsRowButton(title: L10n.Settings.accountManagement, icon: SFIconModel("chevron.right")) {
                    }
                }
//                .alert(
//                    L10n.Settings.Logout.areyousure,
//                    isPresented: $model.isPresentingSignOutConfirm,
//                    actions: {
//                        Button(L10n.Settings.logout, role: .destructive) {
//                        }
//                    }, message: {
//                        Text(L10n.Settings.Logout.areYouSureMessage)
//                    }
//                )
                .textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
        }
    }
}
