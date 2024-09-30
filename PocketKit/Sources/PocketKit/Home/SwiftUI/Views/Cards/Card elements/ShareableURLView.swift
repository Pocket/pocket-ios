// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization

/// A view that retrieves a shareable URL and opens the share sheet when tapped.
struct ShareableURLView: View {
    let card: HomeCard

    @State private var shareableURL: URL?

    var body: some View {
        ZStack {
            if let shareableURL {
                ShareLink(item: shareableURL) {
                    HStack {
                        Text(Localization.ItemAction.share)
                        Spacer()
                        Image(asset: .share)
                    }
                }
            }
        }
        .onAppear {
            // assign a default url in case the fetch fails
            if let temporaryURL = URL(string: card.givenURL) {
                shareableURL = temporaryURL
            }
            Task { @MainActor in
                await shareableUrl()
            }
        }
    }

    func shareableUrl() async {
        if let urlString = await card.shareableUrl(),
           let url = URL(string: urlString) {
            shareableURL = url
        }
    }
}
