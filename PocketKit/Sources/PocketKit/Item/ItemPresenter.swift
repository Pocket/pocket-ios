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
    private var item: SavedItem

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
        self.item = item
        self.index = index
        self.source = source
        self.tracker = tracker
        self.contexts = contexts
    }

    public var title: String {
        [item.title, item.url?.absoluteString]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    public var detail: String {
        [domain, timeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    public var domain: String? {
        item.domainMetadata?.name ?? item.domain
    }

    public var timeToRead: String? {
        item.timeToRead > 0 ? "\(item.timeToRead) min" : nil
    }

    public var thumbnailURL: URL? {
        item.thumbnailURL
    }

    public var isFavorite: Bool {
        item.isFavorite
    }

    public var activityItems: [Any] {
        return [
            item.url.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
    }

    func favorite() {
        source.favorite(item: item)
        track(identifier: .itemFavorite)
    }

    func unfavorite() {
        source.unfavorite(item: item)
        track(identifier: .itemUnfavorite)
    }

    func archive() {
        source.archive(item: item)
        track(identifier: .itemArchive)
    }

    func delete() {
        source.delete(item: item)
        track(identifier: .itemDelete)
    }

    func share() {
        isShareSheetPresented = true
        track(identifier: .itemShare)
    }

    private func track(identifier: UIIdentifier) {
        guard let url = item.url else {
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
