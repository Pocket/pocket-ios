// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

private let constants = ListItem.Constants.actionButton

extension Image {
    func actionButtonStyle(selected: Bool = false, trailingPadding: Bool = true) -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .foregroundColor(selected ? Color(.branding.amber4) : Color(.ui.grey5))
            .scaledToFit()
            .frame(width: constants.imageSize, height: constants.imageSize, alignment: .center)
            .padding(trailingPadding ? [.all] : [.vertical, .leading], constants.padding)
    }
}
