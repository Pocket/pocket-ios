// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct UIKitHomeActionButton: View {
    private var itemAction: ItemAction?
    private var selected: Bool = false

    init(_ itemAction: ItemAction?, selected: Bool = false) {
        self.itemAction = itemAction
        self.selected = selected
    }

    var body: some View {
        if let action = itemAction, let handler = action.handler, let image = action.image {
            Button {
                handler {}
            } label: {
                Image(uiImage: image)
                    .actionButtonStyle(selected: selected)
                    .accessibilityIdentifier(action.accessibilityIdentifier)
                    .accessibilityLabel(action.title)
            }.buttonStyle(.borderless)
        }
    }
}
