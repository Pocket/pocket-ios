// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct ItemTags: View {
    private let constants = ListItem.Constants.tags.self
    var tags: [NSAttributedString]?
    var tagCount: NSAttributedString?

    var body: some View {
        if let tags = tags {
            ForEach(tags.prefix(2), id: \.self) { tag in
                TagComponent(tag: tag)
            }
        }

        if let tagCount = tagCount {
            Text(tagCount.string)
                .style(.listItem.tagCount)
                .lineLimit(constants.maxLines)
        }
    }
}
