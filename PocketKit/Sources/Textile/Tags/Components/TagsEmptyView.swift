// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct TagsEmptyView: View {
    let emptyStateText: String

    var body: some View {
        // TODO: Empty State View (IN-779)
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text(emptyStateText)
                .style(.tags.emptyStateText)
                .padding()
            Spacer()
        }
    }
}

struct TagsEmptyView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        TagsEmptyView(emptyStateText: "Organize your items with Tags.\n To create a tag, enter one below.")
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

        TagsEmptyView(emptyStateText: "Organize your items with Tags.\n To create a tag, enter one below.")
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
    }
}
