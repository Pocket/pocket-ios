// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct TagComponent: View {
    var tag: NSAttributedString

    let constants = ListItem.Constants.tags.self

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(asset: .tag)
                .tagIconStyle()
            Text(tag.string.lowercased())
                .style(.listItem.tag)
                .lineLimit(constants.maxLines)
        }
        .tagBodyStyle()
        .accessibilityIdentifier("Article tag \(tag.string)")
    }
}
