// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct SubscriptionIfoRow: View {
    let item: LabeledText

    var body: some View {
        HStack {
            Text(item.title)
                .style(Style.itemTitle)
            Spacer()
            if item.text.isEmpty {
                redacted
            } else {
                Text(item.text)
                    .style(Style.itemValue)
            }
        }
    }

    private var redacted: some View {
        Text(String(repeating: " ", count: 8))
            .redacted(reason: .placeholder)
    }
}

private extension Style {
    static let itemTitle = Style.header.sansSerif.h7.with(weight: .regular)
    static let itemValue = Style.header.sansSerif.h7.with(weight: .medium)
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionIfoRow(item: LabeledText(title: "Pocket iOS Rocks", text: "Yes it does"))
    }
}
