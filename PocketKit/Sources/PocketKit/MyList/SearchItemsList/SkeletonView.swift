// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct SkeletonView: View {
    private enum Constants {
        static let titleHeight: CGFloat = 60
        static let spacing: CGFloat = 12
    }

    var body: some View {
        List {
            ForEach(0..<15) { _ in
                HStack {
                    VStack(alignment: .leading) {
                        Image(asset: .itemSkeletonTitle)
                            .resizable()
                            .frame(height: Constants.titleHeight)
                        Image(asset: .itemSkeletonTags)
                    }
                    Spacer()
                    VStack(spacing: Constants.spacing) {
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
