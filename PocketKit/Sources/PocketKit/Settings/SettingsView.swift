import SwiftUI
import Textile

class SettingsViewController: UIHostingController<SettingsView> {
    override init(rootView: SettingsView) {
        super.init(rootView: rootView)

        UITableView.appearance(whenContainedInInstancesOf: [Self.self]).backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }
}

struct SettingsView: View {
    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 16.0, *) {
                SettingsForm(model: model)
                    .scrollContentBackground(.hidden)
                    .background(Color(.ui.white1))
            } else {
                SettingsForm(model: model)
                    .background(Color(.ui.white1))
            }
        }
        .navigationBarTitle(L10n.settings, displayMode: .large)
        .accessibilityIdentifier("account")
    }
}

struct SettingsForm: View {
    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        Form {
            Group {
                topSectionWithLeadingDivider()
                    .textCase(nil)

                Section(header: Text(L10n.appCustomization).style(.settings.header)) {
                    SettingsRowToggle(title: L10n.showAppBadgeCount, model: model) {
                        model.toggleAppBadge()
                    }
                }.textCase(nil)

                Section(header: Text(L10n.aboutSupport).style(.settings.header)) {
                    SettingsRowButton(title: L10n.help, icon: SFIconModel("questionmark.circle")) { model.isPresentingHelp.toggle() }
                        .sheet(isPresented: $model.isPresentingHelp) {
                            SFSafariView(url: URL(string: "https://help.getpocket.com")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: L10n.termsOfService, icon: SFIconModel("doc.plaintext")) { model.isPresentingTerms.toggle() }
                        .sheet(isPresented: $model.isPresentingTerms) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/tos/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: L10n.privacyPolicy, icon: SFIconModel("doc.plaintext")) { model.isPresentingPrivacy.toggle() }
                        .sheet(isPresented: $model.isPresentingPrivacy) {
                            SFSafariView(url: URL(string: "https://getpocket.com/en/privacy/")!)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                }.textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
            settingsCredits()
        }
    }

    private struct settingsCredits: View {
        let appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let buildNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        var body: some View {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text(L10n.Settings.pocketForiOS(buildNumber, appVersion))
                        .style(.credits)
                        .padding([.bottom], 6)
                    Text(L10n.Settings.Thankyou.credits)
                        .style(.credits)
                }
                Spacer()
            }
        }
    }
}

// MARK: Top Section
// These methods should be removed once we support iOS 16+
extension SettingsForm {
    /// Handles top section separator on different versions of iOS
    @ViewBuilder
    private func topSectionWithLeadingDivider() -> some View {
        if #available(iOS 16.0, *) {
            topSection()
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    return 0
                }
        } else {
            topSection()
        }
    }

    /// Provides the standard top section view
    private func topSection() -> some View {
        Section(header: Text(L10n.yourAccount).style(.settings.header)) {
            if !model.isPremium {
            Section(header: Text(L10n.yourAccount).style(.settings.header)) {
                if !model.isPremium {
                    SettingsRowButton(
                        title: L10n.Settings.premiumRow,
                        leadingImageAsset: .premiumIcon,
                        trailingImageAsset: .chevronRight,
                        tintColor: Color(.ui.black1)
                    ) {
                        model.showPremiumUpgrade()
                    }
                    .sheet(isPresented: $model.isPresentingPremiumUpgrade) {
                        PremiumUpgradeView(viewModel: model.makePremiumUpgradeViewModel())
                    }
                }
                SettingsRowButton(
                    title: L10n.Settings.goPremium,
                    leadingImageAsset: .premiumIcon,
                    trailingImageAsset: .chevronRight,
                    tintColor: Color(.ui.black1)
                ) {
                    model.showPremiumUpgrade()
                }
                .sheet(isPresented: $model.isPresentingPremiumUpgrade) {
                    PremiumUpgradeView(viewModel: model.makePremiumUpgradeViewModel())
                }
            }
            SettingsRowButton(
                title: L10n.signOut,
                titleStyle: .settings.button.signOut,
                icon: SFIconModel(
                    "rectangle.portrait.and.arrow.right",
                    weight: .semibold,
                    color: Color(.ui.apricot1)
                )
            ) { model.isPresentingSignOutConfirm.toggle() }
                .accessibilityIdentifier("sign-out-button")
                .alert(
                    L10n.areYouSure,
                    isPresented: $model.isPresentingSignOutConfirm,
                    actions: {
                        Button(L10n.signOut, role: .destructive) {
                            model.signOut()
                        }
                    }, message: {
                        Text(L10n.youWillBeSignedOutOfYourAccountAndAnyFilesThatHaveBeenSavedForOfflineViewingWillBeDeleted)
                    }
                )
        }
    }
}

private extension Style {
    static let credits = Style.header.sansSerif.p4.with(color: .ui.grey5)
}
