// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct HighlightRow: View {
    let highlightedQuote: HighlightedQuote
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Divider()
                    .frame(width: 4)
                    .overlay(Appearance.dividerColor)
                Text(highlightedQuote.quote)
            }
            .font(.body)
            .padding(.top, 4)
            HStack(spacing: 16) {
                Spacer()
                Button {
                    // TODO: Add action
                } label: {
                    Image(asset: .share)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.ui.grey8))
                }
                Button {
                    // TODO: Add action
                } label: {
                    Image(asset: .delete)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.ui.grey8))
                }
            }
        }
    }
}

private extension HighlightRow {
    enum Appearance {
        static let dividerColor = Color(uiColor: UIColor(red: 144/255, green: 19/255, blue: 36/255, alpha: 1))
    }
}

#Preview {
    HighlightRow(highlightedQuote: HighlightedQuote(remoteID: "", index: 0, indexPath: IndexPath(), quote: "This is a sample highlight"))
}
