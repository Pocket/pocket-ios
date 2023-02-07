// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct SkeletonView: View {
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                HStack {
                    VStack(alignment: .leading) {
                        Image(asset: .itemSkeletonTitle)
                            .resizable()
                            .frame(height: 60)
                        Image(asset: .itemSkeletonTags)
                    }
                    Spacer()
                    VStack(spacing: 12) {
                        Image(asset: .itemSkeletonThumbnail)
                        Image(asset: .itemSkeletonActions)
                    }
                }.foregroundColor(Color(.ui.skeletonCellImageBackground))
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("skeleton-view")
    }
}
