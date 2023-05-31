// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct PremiumStatusRow: View {
    var title: String

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            Text(title)
                .style(Style.itemTitle)
            Spacer()
            Image(uiImage: UIImage(asset: .chevronRight)).renderingMode(.template).foregroundColor(Color(.ui.black1))
        }
    }
}

private extension Style {
    static let itemTitle = Style.header.sansSerif.h7.with(weight: .regular)
}
