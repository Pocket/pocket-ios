// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct SectionHeader: View {
    let title: String
    let action: () -> Void
    var body: some View {
        HStack {
            Text(title)
                .style(.homeHeader.sectionHeader)
            Spacer()
            Button(action: {
                action()
            }) {
                HStack {
                    Text(Localization.seeAll)
                        .style(.homeHeader.buttonText)
                    Image(asset: .chevronRight)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(.ui.teal2))
                        .frame(width: 6.75, height: 12)
                }
            }
        }
    }
}
