// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Textile

@MainActor
struct DeleteAccountView: View {
    /// If the user is premium
    @State var isPremium: Bool

    /// Confirmation by the user that they have cancelled their premium account
    @State var hasCancelledPremium: Bool = false

    /// Confirmation by the user they they understand the deletion is permanent
    @State var understandsPermanentDeletion: Bool = false

    /// State variable listened on from our view model
    @State var isPresentingCancelationHelp: Bool

    var deleteAccount: () -> Void

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(L10n.Settings.AccountManagement.deleteYourAccount)
                    .style(.settings.header.with(weight: .bold))

                Spacer()

                Text(L10n.Settings.AccountManagement.DeleteAccount.warning)
                    .style(.body.sansSerif.with(weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                if isPremium {
                    Toggle(isOn: $hasCancelledPremium, label: {
                        Text(L10n.Settings.AccountManagement.DeleteAccount.premiumConfirmation)
                            .multilineTextAlignment(.leading)
                    })
                    .padding()
                    .foregroundColor(.black)
                    .toggleStyle(iOSCheckboxToggleStyle())
                }

                Toggle(isOn: $understandsPermanentDeletion, label: {
                    Text(L10n.Settings.AccountManagement.DeleteAccount.deletionConfirmation)
                        .multilineTextAlignment(.leading)
                })
                .padding()
                .foregroundColor(.black)
                .toggleStyle(iOSCheckboxToggleStyle())

                Spacer()

                if isPremium {
                    Button(L10n.Settings.AccountManagement.DeleteAccount.howToCancel) {
                        isPresentingCancelationHelp.toggle()
                    }

                    Spacer()
                }

                Button(L10n.Settings.AccountManagement.deleteAccount) {
                    deleteAccount()
                }
                .buttonStyle(PocketButtonStyle(.primary))
                .disabled(
                    isPremium ?
                          !(hasCancelledPremium && understandsPermanentDeletion) :
                            !understandsPermanentDeletion
                )
                .padding()

                Button(L10n.cancel) {
                    dismiss()
                }
                .buttonStyle(PocketButtonStyle(.secondary))
                .padding()
            }
            .navigationTitle(L10n.Settings.accountManagement)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                Button(action: {
                    dismiss()
                }) {
                    Text(L10n.close)
                }
            )
        }.sheet(isPresented: $isPresentingCancelationHelp) {
            SFSafariView(url: LinkedExternalURLS.CancelingPremium)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct DeleteAccountView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(isPremium: false, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Free User")

        DeleteAccountView(isPremium: true, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Premium User")
    }
}
