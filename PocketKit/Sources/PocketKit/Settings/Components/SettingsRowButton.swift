import SwiftUI
import Textile

struct SettingsRowButton: View {
    
    var title: String
    var titleStyle: Style = .settings.row.default
    var icon: SFIconModel? = nil
    var imageColor: Color = Color(.ui.black)
    
    let action: () -> Void
    
    var body: some View {
        Button {
            self.action()
        } label: {
            HStack(spacing: 0) {
                Text(title)
                    .style(titleStyle)
                Spacer()
                
                if let icon = icon {
                    SFIcon(icon)
                }
            }
            .padding(.vertical, 5)
            
        }
    }
}
