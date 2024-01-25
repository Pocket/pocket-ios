// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

class HighlightsViewController: UIHostingController<HighlightsView> {
    convenience init(highlights: [HighlightedQuote], viewModel: SavedItemViewModel) {
        self.init(rootView: HighlightsView(highlights: highlights, viewModel: viewModel))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }
}

struct HighlightsView: View {
    let highlights: [HighlightedQuote]
    @ObservedObject var viewModel: SavedItemViewModel
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        HStack {
            VStack {
                Image(asset: .highlights)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(.ui.grey8))
                    .padding(.leading, 36)
                Spacer()
            }
            .frame(width: 36)
            VStack(alignment: .leading) {
                Text(Localization.ItemAction.showHighlights)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(.ui.grey8))
                    .padding(.leading)
                Divider()
                    .padding(.leading)
                    .padding(.trailing)
                List(highlights) { highlight in
                    HighlightRow(highlightedQuote: highlight, viewModel: viewModel, modalDismiss: dismiss)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            dismiss()
                            viewModel.scrollToIndexPath(highlight.indexPath)
                        }
                }
                .listStyle(.plain)
            }
            .padding(.trailing, 16)
        }
        .padding(.top)
    }
}
