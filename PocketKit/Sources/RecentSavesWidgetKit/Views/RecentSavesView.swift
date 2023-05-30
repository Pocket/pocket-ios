// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile

/// Main view of the Recent Saves widget
struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        if case let .items(items) = entry.contentType {
            SavedItemsView(items: items)
        } else {
            makeEmptyContentView(entry.contentType)
        }
    }

    private func makeEmptyContentView(_ contentType: RecentSavesContentType) -> some View {
        Text(emptyContentMessage(contentType))
        // TODO: add formatting and colors
    }

    private func emptyContentMessage(_ contentType: RecentSavesContentType) -> String {
        switch contentType {
        case .empty:
            return "Add saves to Pocket to see them in here."
        case .loggedOut:
            return "Log in to Pocket to see your recent saves."
        case .error:
            return "Something went wrong."
        default:
            return ""
        }
    }
}
