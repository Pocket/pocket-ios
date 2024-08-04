// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile
import Localization

struct SettingsView: View {
    @ObservedObject var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingsForm(model: model)
                .scrollContentBackground(.hidden)
                .background(Color(.ui.white1))
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
    @ObservedObject var model: AccountViewModel

    var body: some View {
        Form {
            Group {
                if model.showDebugMenu {
                    Section(header: Text("Developer mode").style(.settings.header)) {
                        SettingsRowButton(title: "Debug menu", icon: SFIconModel("ladybug.fill")) {
                            model.isPresentingDebugMenu.toggle()
                        }
                        .sheet(isPresented: $model.isPresentingDebugMenu) {
                            DebugMenuView(viewModel: model)
                        }
                    }
                    .textCase(nil)
                }
                accountSectionWithLeadingDivider()
                    .textCase(nil)
                Section(header: Text(Localization.appCustomization).style(.settings.header)) {
                    VStack {
                        if !model.isAnonymous {
                            Toggle(Localization.showAppBadgeCount, isOn: model.$appBadgeToggle)
                                .accessibilityIdentifier("app-badge-toggle")
                        }
                        Toggle(Localization.Settings.alwaysOpenOriginalView, isOn: model.$originalViewToggle)
                            .accessibilityIdentifier("original-view-toggle")
                        // Custom implementation to hide the > arrow and let us use our own.
                        if !ProcessInfo.processInfo.isiOSAppOnMac, !ProcessInfo.processInfo.isMacCatalystApp {
                            ZStack {
                                // TODO: this method of programmatic navigation is deprecated. This entire view needs to be migrated to the SwiftUI navigation
                                NavigationLink(destination: SelectIconView(viewModel: model.makeSelectIconViewModel()), isActive: $model.isPresentingIconSwitcher) {
                                    EmptyView()
                                }
                                .opacity(0.0)
                                .buttonStyle(PlainButtonStyle())
                                SettingsRowButton(title: Localization.Settings.AppIcon.title, trailingImageAsset: .chevronRight) {
                                    model.trackAppIconTapped()
                                }
                                .accessibilityIdentifier("app-icon-button")
                            }
                        }
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
                            SFSafariView(url: LinkedExternalURLS.TermsOfService, readerMode: true)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: Localization.privacyPolicy, icon: SFIconModel("doc.plaintext")) { model.isPresentingPrivacy.toggle() }
                        .sheet(isPresented: $model.isPresentingPrivacy) {
                            SFSafariView(url: LinkedExternalURLS.PrivacyPolicy, readerMode: true)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    SettingsRowButton(title: Localization.Settings.openSourceLicenses, icon: SFIconModel("doc.plaintext")) { model.isPresentingLicenses.toggle() }
                        .sheet(isPresented: $model.isPresentingLicenses) {
                            SFSafariView(url: LinkedExternalURLS.OpenSourceNotices, readerMode: true)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                }
                .textCase(nil)
            }
            .listRowBackground(Color(.ui.grey7))
            settingsCredits()
        }
        .onChange(of: model.appBadgeToggle) { newValue in
            model.toggleAppBadge(to: newValue)
        }
        .onChange(of: model.originalViewToggle) { newValue in
            model.toggleOriginalView(to: newValue)
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

// MARK: Account Section
extension SettingsForm {
    /// Handles account section separator to take up the entire space
    private func accountSectionWithLeadingDivider() -> some View {
        accountSection()
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                return 0
            }
    }

    /// Builds the header of the account section
    /// - Returns: the header
    private func accountSectionHeader() -> some View {
        let padding: CGFloat = model.isAnonymous ? 0 : 16

        return VStack(alignment: .leading, spacing: 4) {
            Text(Localization.yourAccount)
                .style(.settings.header)
            if !model.isAnonymous {
                Text(model.userEmail)
                    .style(.credits)
            }
        }
        .padding(.bottom, padding)
    }

    /// Builds the account section
    /// - Returns: the account section
    @ViewBuilder
    private func accountSection() -> some View {
        if model.isAnonymous {
            anonymousAccountSection()
        } else {
            authenticatedAccountSection()
        }
    }
    /// Builds the account section for an authenticated user
    private func authenticatedAccountSection() -> some View {
        Section(header: accountSectionHeader()) {
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
                        }.accessibilityIdentifier("alert-log-out-button")
                    }, message: {
                        Text(Localization.Settings.Logout.areYouSureMessage)
                    }
                )
        }
    }
    /// Builds the account section for an anonymous user
    private func anonymousAccountSection() -> some View {
        Section(header: accountSectionHeader()) {
            SettingsRowButton(
                title: Localization.Settings.singUpOrSignIn,
                titleStyle: .settings.button.default,
                icon: SFIconModel(
                    "person",
                    weight: .semibold,
                    color: Color(.ui.black1)
                )
            ) {
                model.signupOrSignin()
            }
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
