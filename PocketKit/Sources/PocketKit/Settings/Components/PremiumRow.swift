import SwiftUI
import Textile

enum PremiumStatus {
    case notSubscribed
    case subscribed
    
    var title: String {
        switch self {
            case .notSubscribed: return "Not Subscribed"
            case .subscribed: return "Premium Subscriber"
        }
    }
    var style: Style {
        switch self {
            case .notSubscribed: return .settings.rowInactive
            case .subscribed: return .settings.rowActive
        }
    }
}

struct PremiumRow<Destination: View>: View {
    
    @State
    var isActive: Bool = false
    
    var status: PremiumStatus
    var destination: Destination
    
    var body: some View {
        Button(action: {
            isActive.toggle()
        }){
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Premium Status:")
                            .style(.settings.rowHeader)
                        Text(status.title)
                            .style(status.style)
                    }
                    Spacer()
                    SFIcon(SFIconModel("chevron.right", color: Color(.ui.black)))
                }
                .padding(.vertical, 5)
                NavigationLink(destination: destination, isActive: $isActive) {EmptyView()}.hidden()
            }
        }
    }
}
