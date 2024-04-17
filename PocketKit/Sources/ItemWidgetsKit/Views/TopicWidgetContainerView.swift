// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

/// Main view of an Item widget
@available(iOS 17.0, *)
struct TopicWidgetContainerView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment (\.dynamicTypeSize)
    private var textSize

    /// The list of saved items to be displayed
    let entry: TopicEntry

    private var hasVeryLargeFonts: Bool {
        textSize > .xLarge
    }

    private var maxNumberOfItems: Int {
        switch widgetFamily {
        case .systemMedium:
            return hasVeryLargeFonts ? 1 : 2
        case .systemLarge:
            return hasVeryLargeFonts ? 3 : 4
        default:
            // we will need to add more values if we support more widget families
            return 4
        }
    }

    var body: some View {
        makeContainerView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) {
                Color(.ui.white1)
            }
    }

    @ViewBuilder
    private func makeContainerView() -> some View {
        ItemWidgetsView(items: entry.content.items, title: entry.content.name)
            .hasVeryLargeFonts(hasVeryLargeFonts)
            .maxNumberOfItems(maxNumberOfItems)
    }
}
