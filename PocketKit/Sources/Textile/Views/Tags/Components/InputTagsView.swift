// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct InputTagsView: View {
    let tags: [String]
    let removeTag: (String) -> Void

    @Namespace
    var animation

    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                ForEach(getRows(screenWidth: geometry.size.width), id: \.self) { rows in
                    HStack(spacing: Constants.tagsHorizontalSpacing) {
                        ForEach(rows, id: \.self) { row in
                            RowView(tag: row)
                        }
                    }
                }
            }.padding()
            Divider()
                .frame(height: 10)
                .overlay(Color(.ui.grey7))
        }
    }

    func RowView(tag: String) -> some View {
        HStack {
            Text(tag)
                .style(.tags.tag)
            Image(asset: .remove)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                    .frame(width: 5, height: 5)
                    .foregroundColor(Color(.ui.grey4))
                    .padding(.trailing, 4)
        }
        .padding(Constants.tagPadding)
        .background(Rectangle().fill(Color(.ui.grey6)))
        .cornerRadius(4)
        .lineLimit(1)
        .onTapGesture {
            removeTag(tag)
        }
        .accessibilityIdentifier("tag")
        .matchedGeometryEffect(id: tag, in: animation)
    }

    func getRows(screenWidth: CGFloat) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []

        var totalWidth: CGFloat = 0
        let safeWidth: CGFloat = screenWidth
        let padding: CGFloat = Constants.tagPadding * 2 + Constants.tagsHorizontalSpacing * 2
        let closeImage: CGFloat = 5 + 6

        tags.forEach { tag in
            let attributes = Style.tags.tag.textAttributes
            let tagWidth: CGFloat = tag.size(withAttributes: attributes).width + closeImage + padding

            totalWidth += tagWidth

            if totalWidth > safeWidth {
                totalWidth = (!currentRow.isEmpty || rows.isEmpty ? tagWidth : 0)
                rows.append(currentRow)
                currentRow.removeAll()
                currentRow.append(tag)
            } else {
                currentRow.append(tag)
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
            currentRow.removeAll()
        }
        return rows
    }
}

struct InputTagsView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: String) in
            print("\(tag) action")
        }

        GeometryReader { reader in
            InputTagsView(
                tags: ["tag 0", "tag 1", "tag 2", "tag 3", "tag 4", "tag 5", "tag 6", "this is going to be a long tag"],
                removeTag: tagAction,
                geometry: reader)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Light")
        .preferredColorScheme(.light)

        GeometryReader { reader in
            InputTagsView(
                tags: ["tag 0", "tag 1", "tag 2", "tag 3", "tag 4", "tag 5", "tag 6", "this is going to be a long tag"],
                removeTag: tagAction,
                geometry: reader)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark")
        .preferredColorScheme(.dark)
    }
}
