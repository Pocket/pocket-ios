// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

/// Header of an item widget
struct ItemWidgetsHeader: View {
    let title: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .style(.widgetHeader)
            Spacer()
            Image(asset: .saved)
                .resizable()
                .foregroundColor(Color(.ui.coral2))
                .frame(width: Appearance.logoWidth, height: Appearance.logoHeight, alignment: .center)
        }
    }
}

// MARK: Appearance
private extension ItemWidgetsHeader {
    enum Appearance {
        static let logoWidth: CGFloat = 18
        static let logoHeight: CGFloat = 16
    }
}
