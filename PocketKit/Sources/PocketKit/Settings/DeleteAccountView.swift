// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
                    .style(.deleteAccountView.header)
                    .padding(.top, 50)
                    .padding()

                Text(L10n.Settings.AccountManagement.DeleteAccount.warning)
                    .style(.deleteAccountView.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                /**
                 Note below we use LocalizedStringKey. This is a total hack. This is because a SwiftUI text object treats Text("testing") differently then Text(someText). When passed as a variable, the Text view performs no localization, but it also does not render the embedded markdown. When cast to a LocalizedStringKey the Text field will try and localize the content (and fail) but it will render the markdown and bold the text.
                 */

                VStack {
                    if isPremium {
                        Toggle(isOn: $hasCancelledPremium, label: {
                            Text(LocalizedStringKey(L10n.Settings.AccountManagement.DeleteAccount.premiumConfirmation))
                                .multilineTextAlignment(.leading)
                        })
                        .toggleStyle(iOSCheckboxToggleStyle())
                        .accessibilityIdentifier("confirm-cancelled")
                    }

                    Toggle(isOn: $understandsPermanentDeletion, label: {
                        Text(LocalizedStringKey(L10n.Settings.AccountManagement.DeleteAccount.deletionConfirmation))
                            .multilineTextAlignment(.leading)
                    })
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .accessibilityIdentifier("understand-deletion")
                }.padding()

                if isPremium {
                    Button(L10n.Settings.AccountManagement.DeleteAccount.howToCancel) {
                        isPresentingCancelationHelp.toggle()
                    }
                    .padding()
                    .buttonStyle(PocketButtonStyle(.internalInfoLink))
                    .accessibilityIdentifier("how-to-cancel")
                    .if(hasCancelledPremium) { view in
                        // We call hidden here, in an if statement so that the screen does not move the buttons when hasCancelledPremium changes.
                        view.hidden()
                    }
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
                .accessibilityIdentifier("delete-account")

                Button(L10n.cancel) {
                    dismiss()
                }
                .buttonStyle(PocketButtonStyle(.secondary))
                .padding()
                .accessibilityIdentifier("cancel")

                Spacer()
            }
            .navigationTitle(L10n.Settings.accountManagement)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                Button(action: {
                    dismiss()
                }) {
                    Text(L10n.close)
                }.accessibilityIdentifier("close")
            )
        }
        .sheet(isPresented: $isPresentingCancelationHelp) {
            SFSafariView(url: LinkedExternalURLS.CancelingPremium)
                .edgesIgnoringSafeArea(.bottom)
        }
        .accessibilityIdentifier("delete-confirmation")
    }
}

extension Style {
    struct DeleteAccountView {
        let header: Style = Style.header.sansSerif.h2.with(color: .ui.black1)
        let warning: Style = Style.header.sansSerif.p2.with(color: .ui.black1).with(weight: .bold)
        let body: Style = Style.header.sansSerif.p3.with(color: .ui.black1)
    }

    static let deleteAccountView = DeleteAccountView()
}

struct DeleteAccountView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(isPremium: false, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Free User - Light")
            .preferredColorScheme(.light)

        DeleteAccountView(isPremium: false, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Free User - Dark")
            .preferredColorScheme(.dark)

        DeleteAccountView(isPremium: true, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Premium User - Light")
            .preferredColorScheme(.light)
        
        DeleteAccountView(isPremium: true, isPresentingCancelationHelp: false, deleteAccount: {})
            .previewDisplayName("Premium User - Dark")
            .preferredColorScheme(.dark)
    }
}
