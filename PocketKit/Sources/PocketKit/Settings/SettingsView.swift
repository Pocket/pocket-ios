import SharedPocketKit
import SwiftUI
import Textile
import Localization

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
        .navigationBarTitle(Localization.settings, displayMode: .large)
        .accessibilityIdentifier("settings")
        .onDidAppear {
            model.trackSettingsViewed()
        }
    }
}

struct SettingsForm: View {
    @State var dismissReason: DismissReason = .swipe
    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        Form {
            Group {
                topSectionWithLeadingDivider()
                    .textCase(nil)
                Section(header: Text(Localization.appCustomization).style(.settings.header)) {
                    SettingsRowToggle(title: Localization.showAppBadgeCount, model: model) {
                        model.toggleAppBadge()
                    }
                }
                .textCase(nil)
                .sheet(isPresented: $model.isPresentingHooray) {
                    PremiumUpgradeSuccessView()
                }
                Section(header: Text(Localization.aboutSupport).style(.settings.header)) {
                    SettingsRowButton(title: Localization.Settings.help, icon: SFIconModel("questionmark.circle")) { model.isPresentingHelp.toggle() }
                        .sheet(isPresented: $model.isPresentingHelp) {
                            SFSafariView(url: LinkedExternalURLS.Help)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: Localization.termsOfService, icon: SFIconModel("doc.plaintext")) { model.isPresentingTerms.toggle() }
                        .sheet(isPresented: $model.isPresentingTerms) {
                            SFSafariView(url: LinkedExternalURLS.TermsOfService)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: Localization.privacyPolicy, icon: SFIconModel("doc.plaintext")) { model.isPresentingPrivacy.toggle() }
                        .sheet(isPresented: $model.isPresentingPrivacy) {
                            SFSafariView(url: LinkedExternalURLS.PrivacyPolicy)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: Localization.Settings.openSourceLicenses, icon: SFIconModel("doc.plaintext")) { model.isPresentingLicenses.toggle() }
                        .sheet(isPresented: $model.isPresentingLicenses) {
                            SFSafariView(url: LinkedExternalURLS.OpenSourceNotices)
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
                    Text(Localization.Settings.pocketForiOS(buildNumber, appVersion))
                        .style(.credits)
                        .padding([.bottom], 6)
                    Text(Localization.Settings.Thankyou.credits)
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
        Section(header: Text(Localization.yourAccount).style(.settings.header)) {
            if model.isPremium {
                makePremiumSubscriptionRow()
                    .accessibilityIdentifier("premium-subscription-button")
            } else {
                makeGoPremiumRow()
                    .accessibilityIdentifier("go-premium-button")
            }

            // Custom implementation to hide the > arrow and let us use our own.
            ZStack {
                NavigationLink(destination: AccountManagementView(model: model)) {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                SettingsRowButton(title: Localization.Settings.accountManagement, trailingImageAsset: .chevronRight) {
                    model.trackAccountManagementTapped()
                }
                .accessibilityIdentifier("account-management-button")
            }

            SettingsRowButton(
                title: Localization.Settings.logout,
                titleStyle: .settings.button.signOut,
                icon: SFIconModel(
                    "rectangle.portrait.and.arrow.right",
                    weight: .semibold,
                    color: Color(.ui.apricot1)
                )
            ) {
                model.trackLogoutRowTapped()
                model.isPresentingSignOutConfirm.toggle()
            }
                .accessibilityIdentifier("log-out-button")
                .alert(
                    Localization.Settings.Logout.areyousure,
                    isPresented: $model.isPresentingSignOutConfirm,
                    actions: {
                        Button(Localization.Settings.logout, role: .destructive) {
                            model.trackLogoutConfirmTapped()
                            model.signOut()
                        }
                    }, message: {
                        Text(Localization.Settings.Logout.areYouSureMessage)
                    }
                )
        }
    }

    private func makePremiumRowContent(_ isPremium: Bool) -> some View {
        let title = isPremium ? Localization.Settings.premiumSubscriptionRow : Localization.Settings.goPremiumRow
        let titleStyle: Style = isPremium ? .settings.row.active : .settings.row.default
        let leadingTintColor = isPremium ? Color(.ui.teal2) : Color(.ui.black1)
        let action = isPremium ? { model.showPremiumStatus() } : { model.showPremiumUpgrade() }

        return SettingsRowButton(
            title: title,
            titleStyle: titleStyle,
            leadingImageAsset: .premiumIcon,
            trailingImageAsset: .chevronRight,
            leadingTintColor: leadingTintColor,
            action: action
        )
    }

    private func makeGoPremiumRow() -> some View {
        makePremiumRowContent(false)
            .sheet(
                isPresented: $model.isPresentingPremiumUpgrade,
                onDismiss: {
                    model.trackPremiumDismissed(dismissReason: dismissReason)
                    if dismissReason == .system {
                        model.isPresentingHooray = true
                    }
            }
            ) {
                PremiumUpgradeView(dismissReason: self.$dismissReason, viewModel: model.makePremiumUpgradeViewModel())
            }
            .task {
                model.trackPremiumUpsellViewed()
            }
    }

    private func makePremiumSubscriptionRow() -> some View {
        makePremiumRowContent(true)
            .sheet(isPresented: $model.isPresentingPremiumStatus) {
                PremiumStatusView(viewModel: model.makePremiumStatusViewModel())
            }
    }
}

private extension Style {
    static let credits = Style.header.sansSerif.p4.with(color: .ui.grey5)
}
