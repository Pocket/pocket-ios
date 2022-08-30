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
        VStack(spacing:0) {
            Form {
                Section(header: Text("Your Account").style(.settings.header)) {
                    PremiumRow(status: .subscribed, destination: EmptyView())
                    SettingsRowLink(title: "Reset Password", destination: EmptyView())
                    SettingsRowLink(title: "Delete Account", destination: EmptyView())
                }.textCase(nil)
                
                Section() {
                    SettingsRowButton(title: "Sign Out", titleStyle: .settings.button.signOut, icon: SFIconModel("rectangle.portrait.and.arrow.right", weight: .semibold, color: Color(.ui.apricot1))) { model.signOut() }
                }
                
                Section(header: Text("About & Support").style(.settings.header)) {
                    SettingsRowButton(title: "Help", icon: SFIconModel("questionmark.circle")) { model.helpPresented.toggle() }
                        .sheet(isPresented: $model.helpPresented) {
                            SFSafariView(url: URL(string: "https://help.getpocket.com")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: "Terms of Service", icon: SFIconModel("doc.plaintext")) { model.termsPresented.toggle() }
                        .sheet(isPresented: $model.termsPresented) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/tos/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: "Privacy Policy", icon: SFIconModel("doc.plaintext")) { model.privacyPresented.toggle() }
                        .sheet(isPresented: $model.privacyPresented) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/privacy/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    
                }.textCase(nil)
            }
        }
        .navigationBarTitle("Settings", displayMode: .large)
    }
}
