import SwiftUI
import Textile

class SettingsViewController: UIHostingController<SettingsView> {
   override init(rootView: SettingsView) {
        super.init(rootView: rootView)

        UITableView.appearance(whenContainedInInstancesOf: [Self.self]).backgroundColor = UIColor(.ui.grey7)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

struct SettingsView: View {

    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            Form {
//                Section(header: Text("Your Account").style(.settings.header)) {
//                    PremiumRow(status: .notSubscribed, destination: EmptyView())
//                    SettingsRowLink(title: "Reset Password", destination: EmptyView())
//                    SettingsRowLink(title: "Delete Account", destination: EmptyView())
//                }.textCase(nil)

                Section(header: Text("Your Account").style(.settings.header)) {
                    SettingsRowButton(title: "Sign Out", titleStyle: .settings.button.signOut, icon: SFIconModel("rectangle.portrait.and.arrow.right", weight: .semibold, color: Color(.ui.apricot1))) { model.isPresentingSignOutConfirm.toggle() }
                }
                .alert("Are you sure?",
                       isPresented: $model.isPresentingSignOutConfirm,
                       actions: {
                    Button("Sign Out", role: .destructive) {
                        model.signOut()
                    }
                }, message: {
                    Text("You will be signed out of your account and any files that have been saved for offline viewing will be deleted.")
                })
                .textCase(nil)

                Section(header: Text("About & Support").style(.settings.header)) {
                    SettingsRowButton(title: "Help", icon: SFIconModel("questionmark.circle")) { model.isPresentingHelp.toggle() }
                        .sheet(isPresented: $model.isPresentingHelp) {
                            SFSafariView(url: URL(string: "https://help.getpocket.com")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: "Terms of Service", icon: SFIconModel("doc.plaintext")) { model.isPresentingTerms.toggle() }
                        .sheet(isPresented: $model.isPresentingTerms) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/tos/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: "Privacy Policy", icon: SFIconModel("doc.plaintext")) { model.isPresentingPrivacy.toggle() }
                        .sheet(isPresented: $model.isPresentingPrivacy) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/privacy/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }

                }.textCase(nil)
            }
        }
        .navigationBarTitle("Settings", displayMode: .large)
    }
}
