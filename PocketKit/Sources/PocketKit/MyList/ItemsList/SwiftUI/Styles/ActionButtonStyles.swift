import SwiftUI

private let constants = ListItem.Constants.actionButton

extension Image {
    func actionButtonStyle(selected: Bool, trailingPadding: Bool) -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .foregroundColor(selected ? Color(.branding.amber4) : Color(.ui.grey5))
            .scaledToFit()
            .frame(width: constants.imageSize, height: constants.imageSize, alignment: .center)
            .padding(trailingPadding ? [.all] : [.vertical, .leading], constants.padding)
    }
}
