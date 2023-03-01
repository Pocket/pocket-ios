// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Textile

@MainActor
struct DeleteAccountView: View {
    @State var isPremium: Bool

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(L10n.Settings.AccountManagement.deleteYourAccount)
                    .style(.settings.header.with(weight: .bold))

                Spacer()

                Text("Warning: this can't be undone")
                    .style(.body.sansSerif.with(weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                if isPremium {
                    Toggle(isOn: $isPremium, label: {
                        Text("To delete your account, you must first **cancel your Premium subscription here.**")
                            .multilineTextAlignment(.leading)
                    })
                    .padding()
                    .foregroundColor(.black)
                    .toggleStyle(iOSCheckboxToggleStyle())
                }

                Toggle(isOn: $isPremium, label: {
                    Text("You understand your Pocket account and data will be **permanently deleted**")
                        .multilineTextAlignment(.leading)
                })
                .padding()
                .foregroundColor(.black)
                .toggleStyle(iOSCheckboxToggleStyle())

                Spacer()

                Button("Delete account") {
                }.buttonStyle(ActionsPrimaryButtonStyle())

                Button(L10n.cancel) {
                }
            }
            .navigationTitle(L10n.Settings.accountManagement)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                }
            )
        }
    }
}

struct DeleteAccountView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(isPremium: false)
            .previewDisplayName("Free User")

        DeleteAccountView(isPremium: true)
            .previewDisplayName("Apple Premium User")

        DeleteAccountView(isPremium: true)
            .previewDisplayName("Google Premium User")

        DeleteAccountView(isPremium: true)
            .previewDisplayName("Web Premium User")
    }
}
