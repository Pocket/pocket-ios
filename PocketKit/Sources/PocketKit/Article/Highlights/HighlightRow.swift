// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct HighlightRow: View {
    let highlightedQuote: HighlightedQuote
    @ObservedObject var viewModel: SavedItemViewModel
    let modalDismiss: DismissAction

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Divider()
                    .frame(width: 4)
                    .overlay(Appearance.dividerColor)
                    .clipShape(.rect(cornerRadius: 2))
                Text(highlightedQuote.quote)
            }
            .font(.body)
            .padding(.top, 4)
            HStack(spacing: 16) {
                Spacer()
                Button {
                    modalDismiss()
                    viewModel.shareHighlight(highlightedQuote.quote)
                } label: {
                    Image(asset: .share)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.ui.grey8))
                }

                Button {
                    modalDismiss()
                    if let ID = highlightedQuote.remoteID {
                        viewModel.deleteHighlight(ID)
                    }
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
