// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct SettingsRowButton: View {
    var title: String
    var titleStyle: Style = .settings.row.default
    var icon: SFIconModel?
    var leadingImageAsset: ImageAsset?
    var trailingImageAsset: ImageAsset?
    var leadingTintColor: Color = Color(.ui.black1)
    var trailingTintColor: Color = Color(.ui.black1)

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            HStack(spacing: 0) {
                if let leadingImageAsset {
                    SettingsButtonImage(color: leadingTintColor, asset: leadingImageAsset)
                        .padding(.trailing)
                }
                Text(title)
                    .style(titleStyle)
                Spacer()

                if let icon = icon {
                    SFIcon(icon)
                }
                if let trailingImageAsset {
                    SettingsButtonImage(color: trailingTintColor, asset: trailingImageAsset)
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
