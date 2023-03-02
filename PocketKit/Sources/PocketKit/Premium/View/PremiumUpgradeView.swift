import SwiftUI
import Textile

struct PremiumUpgradeView: View {
    // TODO: remove this property and the two @State properties once we are ready to ship premium upgrades to beta users
    static let shouldAllowUpgrade = false
    @State private var showingMonthlyAlert = false
    @State private var showingAnnualAlert = false
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: PremiumUpgradeViewModel

    init(viewModel: PremiumUpgradeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            dismissButton
            upgradeView
        }
        .padding([.top, .bottom], 20)
        .background(PremiumBackgroundView())
        .task {
            do {
                try await viewModel.requestSubscriptions()
            } catch {
                // TODO: Here we will handle any error providing user feedback if/when needed
                print(error)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }

    private var dismissButton: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(asset: .close).renderingMode(.template).foregroundColor(Color(.ui.grey5))
            }
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
                                if Self.shouldAllowUpgrade {
                                    await viewModel.purchaseMonthlySubscription()
                                } else {
                                    showingMonthlyAlert = true
                                }
                            }
                        }
                        .alert("Comiing Soon!", isPresented: $showingMonthlyAlert) {
                            Button("OK", role: .cancel) { }
                        }
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
                                    if Self.shouldAllowUpgrade {
                                        await viewModel.purchaseAnnualSubscription()
                                    } else {
                                        showingAnnualAlert = true
                                    }
                                }
                            }
                            .alert("Comiing Soon!", isPresented: $showingAnnualAlert) {
                                Button("OK", role: .cancel) { }
                            }
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
            }
            .padding([.leading, .trailing], 32)
        }
    }
}

private struct PremiumUpgradeHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Premium").style(.upgradeHeader)
            Text("Membership").style(.upgradeHeader)
        }
    }
}

private struct PremiumUpgradeFeaturesView: View {
    private let features = [
        "Permanent library of everything you've saved",
        "Ad-free",
        "Suggested tags",
        "Full-text search",
        "Unlimited highlights",
        "Premium fonts"
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
    var body: some View {
        VStack {
            Text("Save 25%")
                .style(.percentSaved)
                .multilineTextAlignment(.center)
        }
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
        self.text = L10n.Premium.Upgradeview.description(monthlyPrice, annualPrice)
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
            }, label: { Text("Privacy Policy").style(.terms) })
            .sheet(isPresented: $showPrivacyPolicy) {
                if let privacyUrl = getUrlFor(typeOf: .privacyPolicy) {
                    SFSafariView(url: privacyUrl)
                }
            }
            .accessibilityIdentifier("privacy-policy")
            Button(action: {
                self.showTermsOfService = true
            }, label: { Text("Terms of Service").style(.terms) })
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

    static let percentSaved = Style.yearlyPremiumRow.with(size: .p3).with(weight: .medium)

    static let info = Style.body.sansSerif.with(size: .p4).with(color: .ui.grey4)

    static let terms = Style.settings.button.default.with(color: .ui.grey4)
}
