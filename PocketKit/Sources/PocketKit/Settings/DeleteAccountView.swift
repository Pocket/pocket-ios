// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import SharedPocketKit
import Analytics
import Localization

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel
    /// Confirmation by the user that they have cancelled their premium account
    @State var hasCancelledPremium: Bool = false
    /// Confirmation by the user they they understand the deletion is permanent
    @State var understandsPermanentDeletion: Bool = false

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(Localization.Settings.AccountManagement.deleteYourAccount)
                    .style(.deleteAccountView.header)
                    .padding(.top, 50)
                    .padding()

                Text(Localization.Settings.AccountManagement.DeleteAccount.warning)
                    .style(.deleteAccountView.warning)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()

                /**
                 Note below we use LocalizedStringKey. This is a total hack. This is because a SwiftUI text object treats Text("testing") differently then Text(someText). When passed as a variable, the Text view performs no localization, but it also does not render the embedded markdown. When cast to a LocalizedStringKey the Text field will try and localize the content (and fail) but it will render the markdown and bold the text.
                 */
                VStack {
                    if viewModel.isPremium {
                        Toggle(isOn: $hasCancelledPremium, label: {
                            Text(LocalizedStringKey(Localization.Settings.AccountManagement.DeleteAccount.premiumConfirmation))
                                .multilineTextAlignment(.leading)
                        })
                        .toggleStyle(iOSCheckboxToggleStyle())
                        .accessibilityIdentifier("confirm-cancelled")
                    }

                    Toggle(isOn: $understandsPermanentDeletion, label: {
                        Text(LocalizedStringKey(Localization.Settings.AccountManagement.DeleteAccount.deletionConfirmation))
                            .multilineTextAlignment(.leading)
                    })
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .accessibilityIdentifier("understand-deletion")
                }.padding()

                if viewModel.isPremium {
                    Button(Localization.Settings.AccountManagement.DeleteAccount.howToCancel) {
                        viewModel.helpCancelPremium()
                    }
                    .padding()
                    .buttonStyle(PocketButtonStyle(.internalInfoLink))
                    .accessibilityIdentifier("how-to-cancel")
                    .if(hasCancelledPremium) { view in
                        // We call hidden here, in an if statement so that the screen does not move the buttons when hasCancelledPremium changes.
                        view.hidden()
                    }
                }

                Button(Localization.Settings.AccountManagement.deleteAccount) {
                    viewModel.deleteAccount()
                }
                .buttonStyle(PocketButtonStyle(.destructive))
                .disabled(
                    viewModel.isPremium ?
                          !(hasCancelledPremium && understandsPermanentDeletion) :
                            !understandsPermanentDeletion
                )
                .padding()
                .accessibilityIdentifier("delete-account")

                Button(Localization.cancel) {
                    viewModel.trackDeleteDismissed(dismissReason: .button)
                    dismiss()
                }
                .buttonStyle(PocketButtonStyle(.secondary))
                .padding()
                .accessibilityIdentifier("cancel")
                Spacer()
            }
            .navigationTitle(Localization.Settings.accountManagement)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                Button(action: {
                    viewModel.trackDeleteDismissed(dismissReason: .closeButton)
                    dismiss()
                }) {
                    Text(Localization.close)
                }.accessibilityIdentifier("close")
            )
        }
        .sheet(isPresented: $viewModel.isPresentingCancelationHelp) {
            SFSafariView(url: LinkedExternalURLS.CancelingPremium)
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
                    viewModel.trackHelpCancelingPremiumImpression()
                }
        }
        .accessibilityIdentifier("delete-confirmation")
        .overlay {
            if viewModel.isDeletingAccount {
                PocketLoadingView.overlay(Localization.Settings.AccountManagement.DeleteAccount.deleting)
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text(Localization.General.oops), message: Text(Localization.Settings.AccountManagement.DeleteAccount.Error.body), dismissButton: .cancel(Text(Localization.ok)))
        }
        .onDidAppear {
            viewModel.trackDeleteConfirmationImpression()
        }
    }
}

struct DeleteAccountView_PreviewProvider: PreviewProvider {
    static func makePreview(isPremium: Bool = false,
                            isPresentingCancellationHelp: Bool = false,
                            isDeletingAccount: Bool = false,
                            showErrorAlert: Bool = false) -> DeleteAccountView {
        DeleteAccountView(
            viewModel: DeleteAccountViewModel(
                isPresentingCancellationHelp: isPresentingCancellationHelp,
                isDeletingAccount: isDeletingAccount,
                showErrorAlert: showErrorAlert,
                isPremium: isPremium,
                userManagementService: PreviewUserManagementService(),
                tracker: PreviewTracker()
            )
        )
    }

    static var previews: some View {
            makePreview()
            .previewDisplayName("Free User - Light")
            .preferredColorScheme(.light)

        makePreview()
            .previewDisplayName("Free User - Dark")
            .preferredColorScheme(.dark)

        makePreview(isPremium: true)
            .previewDisplayName("Premium User - Light")
            .preferredColorScheme(.light)

        makePreview(isPremium: true)
            .previewDisplayName("Premium User - Dark")
            .preferredColorScheme(.dark)

        makePreview(isDeletingAccount: true)
            .previewDisplayName("Deleting Account - Light")
            .preferredColorScheme(.light)

        makePreview(isDeletingAccount: true)
            .previewDisplayName("Deleting Account - Dark")
            .preferredColorScheme(.dark)

        makePreview(showErrorAlert: true)
            .previewDisplayName("Error - Light")
            .preferredColorScheme(.light)

        makePreview(showErrorAlert: true)
            .previewDisplayName("Error - Dark")
            .preferredColorScheme(.dark)
    }
}
