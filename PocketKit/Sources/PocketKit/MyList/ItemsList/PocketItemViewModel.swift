// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Analytics
import Sync
import SharedPocketKit

class PocketItemViewModel: ObservableObject {
    private let tracker: Tracker
    private let source: Source
    let item: PocketItem
    let index: Int

    @Published
    var isFavorite: Bool

    init(item: PocketItem, index: Int, source: Source, tracker: Tracker) {
        self.item = item
        self.index = index
        self.source = source
        self.tracker = tracker
        self.isFavorite = item.isFavorite
    }

    func favoriteAction(index: Int, scope: SearchScope) -> ItemAction {
        if isFavorite {
            return .unfavorite { [weak self] _ in
                self?._unfavorite(index: index, scope: scope)
            }
        } else {
            return .favorite { [weak self] _ in
                self?._favorite(index: index, scope: scope)
            }
        }
    }

    private func _favorite(index: Int, scope: SearchScope) {
        guard
            let id = item.id,
            let savedItem = source.fetchOrCreateSavedItem(
                with: id,
                and: item.remoteItemParts
            )
        else {
            Log.capture(message: "Saved Item not created")
            return
        }

        tracker.track(event: Events.Search.unfavoriteItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.favorite(item: savedItem)
        isFavorite = savedItem.isFavorite
    }

    private func _unfavorite(index: Int, scope: SearchScope) {
        guard
            let id = item.id,
            let savedItem = source.fetchOrCreateSavedItem(
                with: id,
                and: item.remoteItemParts
            )
        else {
            Log.capture(message: "Saved Item not created")
            return
        }

        tracker.track(event: Events.Search.favoriteItem(itemUrl: savedItem.url, positionInList: index, scope: scope))
        source.unfavorite(item: savedItem)
        isFavorite = savedItem.isFavorite
    }

    var shareAction: ItemAction {
        ItemAction.share { _ in Log.info("Share button tapped!") }
    }

    var overflowActions: [ItemAction] {
        [ItemAction.addTags { _ in Log.info("Add tags button tapped!") }, ItemAction.archive { _ in Log.info("Archive button tapped!") }, ItemAction.delete { _ in Log.info("Delete button tapped!") }]
    }

    var trackOverflow: ItemAction {
        ItemAction(title: "", identifier: UIAction.Identifier(rawValue: ""), accessibilityIdentifier: "", image: nil, handler: {_ in
            Log.info("Overflow button tapped!")
        })
    }
}
