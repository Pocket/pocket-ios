// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Textile
import WidgetKit

struct ItemsListEntry: TimelineEntry {
    let date: Date
    let titleColor: ColorAsset
    let content: ItemsWidgetContent

    init(date: Date, name: String, titleColor: ColorAsset = .ui.coral2, contentType: ItemsListContentType) {
        self.date = date
        self.titleColor = titleColor
        self.content = ItemsWidgetContent(name: name, contentType: contentType)
    }
}

struct ItemsWidgetContent {
    let name: String
    let contentType: ItemsListContentType
}

extension ItemsWidgetContent {
    static var sampleContent: ItemsWidgetContent {
        ItemsWidgetContent(
            name: "Sample Topic",
            contentType: .items(
                [
                    ItemRowContent(
                        content: ItemContent(
                            url: "https://getPocket.com",
                            title: "Sample Entry",
                            imageUrl: nil,
                            bestDomain: "https://getPocket.com",
                            timeToRead: 0
                        ),
                        image: nil
                    )
                ]
            )
        )
    }
}

/// Determines which type of content to display in the Recent Saves widget.
enum ItemsListContentType {
    case recentSavesEmpty
    case recommendationsEmpty
    case loggedOut
    case error
    case items([ItemRowContent])
}
