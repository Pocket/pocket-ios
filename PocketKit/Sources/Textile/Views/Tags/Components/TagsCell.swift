// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import SwiftUI

struct TagsCell: View {
    let tag: String
    let tagAction: (String) -> Bool

    var body: some View {
        HStack {
            Text(tag)
                .style(.tags.allTags)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            _ = tagAction(tag)
        }
    }
}

struct TagsCell_PreviewProvider: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: String) -> Bool in
            print("\(tag) action")
            return true
        }

        TagsCell(tag: "test tag", tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

        TagsCell(tag: "test tag", tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
    }
}
