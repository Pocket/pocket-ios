import SwiftUI
import Textile

struct SettingsRowLink<Destination: View>: View {
    
    @State
    var isActive: Bool = false
    
    var title: String
    var titleStyle: Style = .settings.row.default
    var icon: SFIconModel = SFIconModel("chevron.right", color: Color(.ui.black1))
    var destination: Destination
    
    
    var body: some View {
        Button(action: {
            isActive.toggle()
        }){
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(title)
                        .style(titleStyle)
                    Spacer()
                    SFIcon(icon)
                }
                .padding(.vertical, 5)
                NavigationLink(destination: destination, isActive: $isActive) {EmptyView()}.hidden()
            }
        }
    }
}
