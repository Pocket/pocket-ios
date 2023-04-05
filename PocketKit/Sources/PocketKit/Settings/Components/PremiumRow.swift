import SwiftUI
import Textile
import Localization

enum PremiumStatus: String {
    case notSubscribed = "Sign up for Premium"
    case subscribed = "Premium Subscriber"

    var headerVisible: Bool {
        switch self {
        case .notSubscribed: return false
        case .subscribed: return true
        }
    }
    var statusStyle: Style {
        switch self {
        case .notSubscribed: return .settings.button.darkBackground
        case .subscribed: return .settings.row.active
        }
    }
    var foreground: Color {
        switch self {
        case .notSubscribed: return Color(.ui.white)
        case .subscribed: return Color(.ui.black1)
        }
    }
    var background: Color {
        switch self {
        case .notSubscribed: return Color(.ui.coral2)
        case .subscribed: return Color(UIColor.secondarySystemGroupedBackground)
        }
    }

    var localized: String {
        switch self {
        case .notSubscribed: return Localization.signUpForPremium
        case .subscribed: return Localization.premiumSubscriber
        }
    }
}

struct PremiumRow<Destination: View>: View {
    @State var isActive: Bool = false

    var status: PremiumStatus
    var destination: Destination

    var body: some View {
        Button(action: {
            isActive.toggle()
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        if status.headerVisible {
                            Text(Localization.premiumStatus)
                                .style(.settings.row.header)
                        }
                        Text(status.rawValue)
                            .style(status.statusStyle)
                            .padding(.vertical, status.headerVisible ? 0 : 4)
                    }
                    Spacer()
                    SFIcon(SFIconModel("chevron.right", color: status.foreground))
                }
                .padding(.vertical, 5)
                NavigationLink(destination: destination, isActive: $isActive) { EmptyView() }.hidden()
            }
        }.listRowBackground(status.background)
    }
}
