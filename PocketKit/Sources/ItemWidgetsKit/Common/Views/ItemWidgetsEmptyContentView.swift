// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import SwiftUI
import Textile

/// Empty content view of an Item widget
struct ItemWidgetsEmptyContentView: View {
    let contentType: ItemsListContentType

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Image(asset: .labeledIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fixedSize()
            Text(emptyContentMessage(contentType))
                .style(.emptyWidgetMessage)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    private func emptyContentMessage(_ contentType: ItemsListContentType) -> String {
        switch contentType {
        case .recentSavesEmpty:
            return Localization.Widgets.RecentSaves.emptyMessage
        case .recentSavesLoggedOut:
            return Localization.Widgets.RecentSaves.loggedOutMessage
        case .error:
            return Localization.Widgets.RecentSaves.errorMessage
        default:
            return ""
        }
    }
}
