import SwiftUI
import Textile

struct ActionButton: View {
    var itemAction: ItemAction?
    var selected: Bool = false
    var trailingPadding: Bool = true

    init(_ itemAction: ItemAction?, selected: Bool = false, trailingPadding: Bool = true) {
        self.itemAction = itemAction
        self.selected = selected
        self.trailingPadding = trailingPadding
    }

    var body: some View {
        if let action = itemAction, let handler = action.handler, let image = action.image {
            Button {
                handler {}
            } label: {
                Image(uiImage: image)
                    .actionButtonStyle(selected: selected, trailingPadding: trailingPadding)
                    .accessibilityIdentifier(action.accessibilityIdentifier)
            }.buttonStyle(.borderless)
        }
    }
}
