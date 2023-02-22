import SwiftUI
import Textile

struct SettingsRowButton: View {
    var title: String
    var titleStyle: Style = .settings.row.default
    var icon: SFIconModel?
    var leadingImageAsset: ImageAsset?
    var trailingImageAsset: ImageAsset?
    var tintColor: Color?

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            HStack(spacing: 0) {
                if let leadingImageAsset, let tintColor {
                    SettingsButtonImage(color: tintColor, asset: leadingImageAsset)
                        .padding(.trailing)
                }
                Text(title)
                    .style(titleStyle)
                Spacer()

                if let icon = icon {
                    SFIcon(icon)
                }
                if let trailingImageAsset, let tintColor {
                    SettingsButtonImage(color: tintColor, asset: trailingImageAsset)
                }
            }
            .padding(.vertical, 5)
        }
    }
}

struct SettingsButtonImage: View {
    let color: Color
    let asset: ImageAsset

    var body: some View {
        Image(uiImage: UIImage(asset: asset))
            .renderingMode(.template)
            .foregroundColor(color)
    }
}
