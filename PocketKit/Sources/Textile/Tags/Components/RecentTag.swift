// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import SwiftUI

struct RecentTag: View {
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(asset: .tag)
                .tagIconStyle()
            Text("recent")
                .style(.tags.tag)
        }
        .accessibilityIdentifier("recent-tags")
    }
}

private extension Image {
    func tagIconStyle() -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
                .foregroundColor(Color(.ui.grey4))
                .padding(.trailing, (8 - 2))
    }
}

struct RecentTag_PreviewProvider: PreviewProvider {
    static var previews: some View {
        RecentTag()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

        RecentTag()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
    }
}

