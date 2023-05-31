// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile
import Localization

struct PremiumUpgradeView: View {
    @Binding var dismissReason: DismissReason
    @Environment(\.dismiss)
    private var dismiss
    @StateObject var viewModel: PremiumUpgradeViewModel

    var body: some View {
        VStack(spacing: 0) {
            dismissButton
            upgradeView
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium-upgrade-view")
        .padding([.top, .bottom], 20)
        .background(PremiumBackgroundView())
        .banner(data: viewModel.offlineView, show: $viewModel.shouldShowOffline, bottomOffset: CGFloat(4))
        .task {
            viewModel.trackPremiumUpgradeViewShown()
            dismissReason = .swipe
            do {
                try await viewModel.requestSubscriptions()
            } catch {
                Log.capture(error: error)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismissReason = .system
                dismiss()
            }
        }
    }

    private var dismissButton: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                self.dismissReason = .button
                dismiss()
            } label: {
                Image(asset: .close).renderingMode(.template).foregroundColor(Color(.ui.grey5))
            }
            .accessibilityIdentifier("premium-upgrade-view-dismiss-button")
            .padding(.top, 10)
            .padding([.leading, .trailing], 32)
        }
    }

    struct OffsetConstant {
        static var offsetX: CGFloat = 10
        static var offsetY: CGFloat = -30
    }

    private var upgradeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 40) {
                PremiumUpgradeHeader()
                Divider().background(Color(.ui.grey1))
                PremiumUpgradeFeaturesView()
                if !viewModel.isOffline {
                    HStack {
                        if viewModel.monthlyName.isEmpty {
                            PremiumUpgradeButton(isYearly: false)
                                .redacted(reason: .placeholder)
                        } else {
                            PremiumUpgradeButton(
                                text: viewModel.monthlyName,
                                pricing: viewModel.monthlyPriceDescription,
                                isYearly: false
                            ) {
                                Task {
                                    viewModel.trackMonthlyButtonTapped()
                                    await viewModel.purchaseMonthlySubscription()
                                }
                            }
                            .accessibilityIdentifier("premium-upgrade-view-monthly-button")
                        }
                        Spacer().frame(width: 28)
                        ZStack(alignment: .topTrailing) {
                            if viewModel.annualName.isEmpty {
                                PremiumUpgradeButton(isYearly: true)
                                    .redacted(reason: .placeholder)
                            } else {
                                PremiumUpgradeButton(
                                    text: viewModel.annualName,
                                    pricing: viewModel.annualPriceDescription,
                                    isYearly: true
                                ) {
                                    Task {
                                        viewModel.trackAnnualButtonTapped()
                                        await viewModel.purchaseAnnualSubscription()
                                    }
                                }
                                .accessibilityIdentifier("premium-upgrade-view-annual-button")
                                PremiumYearlyPercent()
                                    .offset(x: OffsetConstant.offsetX, y: OffsetConstant.offsetY)
                            }
                        }
                    }
                    if viewModel.monthlyPrice.isEmpty, viewModel.annualPrice.isEmpty {
                        PremiumInfoView(monthlyPrice: viewModel.monthlyPrice, annualPrice: viewModel.annualPrice)
                            .redacted(reason: .placeholder)
                    } else {
                        PremiumInfoView(monthlyPrice: viewModel.monthlyPrice, annualPrice: viewModel.annualPrice)
                    }
                    PremiumTermsView()
                } else {
                    VStack {}
                        .task {
                            viewModel.shouldShowOfflineBanner()
                        }
                }
            }
            .padding([.leading, .trailing], 32)
        }
    }
}

private struct PremiumUpgradeHeader: View {
    var body: some View {
        Text(Localization.Premium.UpgradeView.premiumMembership).style(.upgradeHeader)
    }
}

private struct PremiumUpgradeFeaturesView: View {
    private let features = [
        Localization.Premium.UpgradeView.permanentLibrary,
        Localization.Premium.UpgradeView.adFree,
        Localization.Premium.UpgradeView.suggestedTags,
        Localization.Premium.UpgradeView.fullTextSearch,
        Localization.Premium.UpgradeView.unlimitedHighlights,
        Localization.Premium.UpgradeView.premiumFonts
    ]

    var body: some View {
        VStack(spacing: 24) {
            ForEach(features, id: \.self) {
                PremiumUpgradeFeatureRow(text: $0)
            }
            .listStyle(.plain)
            .disabled(true)
        }
    }
}

private struct PremiumUpgradeFeatureRow: View {
    private let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(asset: .checkMini).renderingMode(.template).foregroundColor(Color(.ui.teal3))
            Text(text).style(.featureRow)
            Spacer()
        }.listRowSeparator(.hidden)
    }
}

private struct PremiumUpgradeButton: View {
    private let text: String
    private let pricing: String
    private let isYearly: Bool
    private var action: (() -> Void)?

    /// The default values are used as placeholders while the actual values are being loaded
    ///  Useful for redacting the Text views while loading
    init(text: String = String(repeating: " ", count: 8),
         pricing: String = String(repeating: " ", count: 10),
         isYearly: Bool,
         action: (() -> Void)? = nil) {
        self.text = text
        self.pricing = pricing
        self.isYearly = isYearly
        self.action = action
    }

    var body: some View {
        if isYearly {
            Button(action: { action?() }) {
                VStack(spacing: 8) {
                    Text(text)
                        .style(.yearlyPremiumRow)
                    Text(pricing)
                        .style(.yearlyPricing)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 53)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(.ui.coral2))
                )
            }
        } else {
            Button(action: { action?() }) {
                VStack(spacing: 8) {
                    Text(text)
                        .style(.monthlyPremiumRow)
                    Text(pricing)
                        .style(.pricing)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 53)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.ui.grey1), lineWidth: 2)
                )
            }
        }
    }
}

private struct PremiumYearlyPercent: View {
    let discountAmount: String = "25%"
    var body: some View {
        Text(Localization.Premium.UpgradeView.save + " " + discountAmount)
            .style(.percentSaved)
            .frame(width: 60, height: 60, alignment: .center)
            .background(Circle().fill(Color(.ui.teal3)))
    }
}

private struct PremiumInfoView: View {
    let monthlyPrice: String
    let annualPrice: String
    private let text: String

    init(monthlyPrice: String, annualPrice: String) {
        self.monthlyPrice = monthlyPrice
        self.annualPrice = annualPrice
        self.text = Localization.Premium.UpgradeView.description(monthlyPrice, annualPrice)
    }

    var body: some View {
        Text(text).style(.info)
    }
}

private struct PremiumTermsView: View {
    @State var showPrivacyPolicy = false
    @State var showTermsOfService = false

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                self.showPrivacyPolicy = true
            }, label: { Text(Localization.Premium.InfoView.Terms.privacyPolicy).style(.terms) })
            .sheet(isPresented: $showPrivacyPolicy) {
                if let privacyUrl = getUrlFor(typeOf: .privacyPolicy) {
                    SFSafariView(url: privacyUrl)
                }
            }
            .accessibilityIdentifier("privacy-policy")
            Button(action: {
                self.showTermsOfService = true
            }, label: { Text(Localization.Premium.InfoView.Terms.termsOfService).style(.terms) })
            .sheet(isPresented: $showTermsOfService) {
                if let toSUrl = getUrlFor(typeOf: .termsOfService) {
                    SFSafariView(url: toSUrl)
                }
            }
            .accessibilityIdentifier("terms-of-service")
        }.padding(.bottom)
    }

    enum Link {
        case privacyPolicy
        case termsOfService
    }

    private func getUrlFor(typeOf: Link) -> URL? {
        switch typeOf {
        case .privacyPolicy:
            guard let privacyUrl = URL(string: "https://getpocket.com/privacy/") else {
                return nil
            }
            return privacyUrl
        case .termsOfService:
            guard let toSUrl = URL(string: "https://getpocket.com/tos/") else {
                return nil
            }
            return toSUrl
        }
    }
}

private struct PremiumBackgroundView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: .premiumBorderTop).resizable().frame(maxHeight: borderWidth)
            sidebars
            Image(asset: .premiumBorderBottom).resizable().frame(maxHeight: borderWidth)
        }
    }

    private var sidebars: some View {
        HStack(spacing: 0) {
            Image(asset: .premiumBorderLeft).resizable().frame(maxWidth: borderWidth)
            Spacer()
            Image(asset: .premiumBorderRight).resizable().frame(maxWidth: borderWidth)
        }
    }

    private var borderWidth: CGFloat {
        CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 18.0 : 13.0)
    }
}

private extension Style {
    static let upgradeHeader = Style.header.display.medium.h1.with { style in
        style.with(alignment: .center)
    }

    static let featureRow = Style.settings.row.default.with(size: .p3)

    static let monthlyPremiumRow = Style.settings.row.default.with(size: .h4).with(weight: .medium)

    static let yearlyPremiumRow = Style.settings.row.darkBackground.default.with(size: .h4).with(weight: .medium)

    static let pricing = Style.featureRow.with(size: .p4)

    static let yearlyPricing = Style.yearlyPremiumRow.with(size: .p4)

    static let percentSaved = Style.yearlyPremiumRow.with(size: .p3).with(weight: .medium).with(alignment: .center)

    static let info = Style.body.sansSerif.with(size: .p4).with(color: .ui.grey4)

    static let terms = Style.settings.button.default.with(color: .ui.grey4)
}
