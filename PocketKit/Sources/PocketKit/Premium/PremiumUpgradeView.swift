import SwiftUI
import Textile

struct PremiumUpgradeView: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            dismissButton
            upgradeView
        }
        .padding([.top, .bottom], 20)
        .background(PremiumBackgroundView())
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
                    PremiumUpgradeButton(text: "TBD", pricing: "$0.00/month", isYearly: false)
                    Spacer().frame(width: 28)
                    ZStack(alignment: .topTrailing) {
                        PremiumUpgradeButton(text: "TBD", pricing: "$0.00/year", isYearly: true)
                        PremiumYearlyPercent()
                            .offset(x: OffsetConstant.offsetX, y: OffsetConstant.offsetY)
                    }
                }
                PremiumInfoView()
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

    init(text: String, pricing: String, isYearly: Bool) {
        self.text = text
        self.pricing = pricing
        self.isYearly = isYearly
    }

    var body: some View {
        if isYearly {
            Button(action: {}) {
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
            Button(action: {}) {
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
    private let text = """
Subscriptions will be charged to your credit card through your iTunes account. \
Your account will be charged $TBD (monthly) or $TBD (yearly) for renewal within 24 hours prior to the end of the current period. \
Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period. \
It will not be possible to immediately cancel a subscription. \
You can manage subscriptions and turn off auto-renewal by going to your account settings after purchase. \
Refunds are not available for unused portions of a subscription.
"""

    var body: some View {
        Text(text).style(.info)
    }
}

private struct PremiumTermsView: View {
    var body: some View {
        HStack(spacing: 16) {
            Button { } label: { Text("Privacy Policy").style(.terms) }
            Button { } label: { Text("Terms of Service").style(.terms) }
        }.padding(.bottom)
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
