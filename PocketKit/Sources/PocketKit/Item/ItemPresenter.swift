// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation
import Sync
import Analytics


class ItemPresenter: ItemRow {
    @Published
    private var savedItem: SavedItem

    private var item: Item? {
        savedItem.item
    }

    @Published
    var isShareSheetPresented = false
    
    let index: Int

    private let source: Source
    private let tracker: Tracker
    private let contexts: [SnowplowContext]

    init(
        item: SavedItem,
        index: Int,
        source: Source,
        tracker: Tracker,
        contexts: [SnowplowContext]
    ) {
        self.savedItem = item
        self.index = index
        self.source = source
        self.tracker = tracker
        self.contexts = contexts
    }

    public var title: String {
        [
            savedItem.item?.title,
            savedItem.bestURL?.absoluteString
        ]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    public var detail: String {
        [domain, timeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    public var domain: String? {
        item?.domainMetadata?.name
        ?? item?.domain
    }

    public var timeToRead: String? {
        guard let timeToRead = item?.timeToRead,
                timeToRead > 0 else {
            return nil
        }

        return "\(timeToRead) min"
    }

    public var thumbnailURL: URL? {
        return imageCacheURL(for: item?.topImageURL)
    }

    public var isFavorite: Bool {
        savedItem.isFavorite
    }

    public var activityItems: [Any] {
        return [
            savedItem.bestURL.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
    }

    func favorite() {
        source.favorite(item: savedItem)
        track(identifier: .itemFavorite)
    }

    func unfavorite() {
        source.unfavorite(item: savedItem)
        track(identifier: .itemUnfavorite)
    }

    func archive() {
        source.archive(item: savedItem)
        track(identifier: .itemArchive)
    }

    func delete() {
        source.delete(item: savedItem)
        track(identifier: .itemDelete)
    }

    func share() {
        isShareSheetPresented = true
        track(identifier: .itemShare)
    }

    private func track(identifier: UIIdentifier) {
        guard let url = savedItem.bestURL else {
            return
        }

        let contexts: [SnowplowContext] = contexts + [
            UIContext.button(identifier: identifier),
            Content(url: url)
        ]

        let event = Engagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }
}
