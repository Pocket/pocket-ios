import SwiftUI
import Textile

struct SettingsRowButton: View {
    var title: String
    var titleStyle: Style = .settings.row.default
    var icon: SFIconModel?
    var leadingImage: UIImage?
    var trailingImage: UIImage?

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            HStack(spacing: 0) {
                if let leadingImage = leadingImage {
                    Image(uiImage: leadingImage)
                        .padding(.trailing)
                }
                Text(title)
                    .style(titleStyle)
                Spacer()

                if let icon = icon {
                    SFIcon(icon)
                }
                if let trailingImage = trailingImage {
                    Image(uiImage: trailingImage)
                }
            }
            .padding(.vertical, 5)
        }
    }
}
