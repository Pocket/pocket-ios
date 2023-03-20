// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import SharedPocketKit
import Analytics

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
                Text(L10n.Settings.AccountManagement.deleteYourAccount)
                    .style(.deleteAccountView.header)
                    .padding(.top, 50)
                    .padding()

                Text(L10n.Settings.AccountManagement.DeleteAccount.warning)
                    .style(.deleteAccountView.warning)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()

                /**
                 Note below we use LocalizedStringKey. This is a total hack. This is because a SwiftUI text object treats Text("testing") differently then Text(someText). When passed as a variable, the Text view performs no localization, but it also does not render the embedded markdown. When cast to a LocalizedStringKey the Text field will try and localize the content (and fail) but it will render the markdown and bold the text.
                 */
                VStack {
                    if viewModel.isPremium {
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

                if viewModel.isPremium {
                    Button(L10n.Settings.AccountManagement.DeleteAccount.howToCancel) {
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

                Button(L10n.Settings.AccountManagement.deleteAccount) {
                    viewModel.deleteAccount()
                }
                .buttonStyle(PocketButtonStyle(.primary))
                .disabled(
                    viewModel.isPremium ?
                          !(hasCancelledPremium && understandsPermanentDeletion) :
                            !understandsPermanentDeletion
                )
                .padding()
                .accessibilityIdentifier("delete-account")

                Button(L10n.cancel) {
                    viewModel.trackDeleteDismissed(dismissReason: .button)
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
                    viewModel.trackDeleteDismissed(dismissReason: .closeButton)
                    dismiss()
                }) {
                    Text(L10n.close)
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
                DeleteLoadingView()
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text(L10n.General.oops), message: Text(L10n.Settings.AccountManagement.DeleteAccount.Error.body), dismissButton: .cancel(Text(L10n.ok)))
        }
        .onDidAppear {
            viewModel.trackDeleteConfirmationImpression()
        }
    }
}

private struct DeleteLoadingView: View {
    var body: some View {
        VStack {
            HStack {
               Spacer()
            }
            Spacer()
            LottieView(.loading)
                .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 100)
            Text(L10n.Settings.AccountManagement.DeleteAccount.deleting).style(.deleteAccountView.overlay)
            Spacer()
        }
        .background(Color(.ui.grey3))
        .foregroundColor(Color(.ui.white1))
        .opacity(0.9)
        .accessibilityIdentifier("deleting-overlay")
    }
}

extension Style {
    struct DeleteAccountView {
        let header: Style = Style.header.sansSerif.h2.with(color: .ui.black1)
        let warning: Style = Style.header.sansSerif.p2.with(color: .ui.black1).with(weight: .bold)
        let body: Style = Style.header.sansSerif.p3.with(color: .ui.black1)
        let overlay: Style = Style.header.sansSerif.p2.with(color: .ui.white).with(weight: .bold)
    }

    static let deleteAccountView = DeleteAccountView()
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
