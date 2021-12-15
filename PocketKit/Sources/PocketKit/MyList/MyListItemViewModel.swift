// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation
import Sync
import Analytics
import CoreData
import UIKit
import Kingfisher


private extension Style {
    static let title: Style = .header.sansSerif.h7
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }

    static let detail: Style = .header.sansSerif.p4
        .with(color: .ui.grey4)
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }

    func forMeasurement() -> Style {
        with { $0.with(lineBreakMode: .none) }
    }
}

class MyListItemViewModel {
    let index: Int
    let savedItem: SavedItem

    private let source: Sync.Source
    private let tracker: Tracker

    private var item: Item? {
        savedItem.item
    }

    init(
        item: SavedItem,
        index: Int,
        source: Sync.Source,
        tracker: Tracker
    ) {
        self.savedItem = item
        self.index = index
        self.source = source
        self.tracker = tracker
    }

    var objectID: NSManagedObjectID {
        savedItem.objectID
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: .title)
    }

    var attributedTitleForMeasurement: NSAttributedString {
        NSAttributedString(string: title, style: .title.forMeasurement())
    }

    var attributedDetail: NSAttributedString {
        NSAttributedString(string: detail, style: .detail)
    }

    var attributedDetailForMeasurement: NSAttributedString {
        NSAttributedString(string: detail, style: .detail.forMeasurement())
    }

    var thumbnailURL: URL? {
        return imageCacheURL(for: item?.topImageURL)
    }

    public var favoriteButtonImage: UIImage? {
        if isFavorite {
            return UIImage(asset: .favoriteFilled)
                .withTintColor(UIColor(.branding.amber4), renderingMode: .alwaysOriginal)
        } else {
            return UIImage(asset: .favorite)
                .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal)
        }
    }

    public var favoriteButtonAccessibilityLabel: String {
        if isFavorite {
            return "Unfavorite"
        } else {
            return "Favorite"
        }
    }

    public func loadThumbnail(into cell: MyListItemCell) {
        cell.thumbnailView.isHidden = thumbnailURL == nil
        cell.thumbnailView.kf.setImage(
            with: thumbnailURL,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    ResizingImageProcessor(
                        referenceSize: MyListItemCell.Constants.thumbnailSize,
                        mode: .aspectFill
                    ).append(
                        another: CroppingImageProcessor(
                            size: MyListItemCell.Constants.thumbnailSize
                        )
                    )
                )
            ]
        )
    }

    private var title: String {
        [
            savedItem.item?.title,
            savedItem.bestURL?.absoluteString
        ]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    private var detail: String {
        [domain, timeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    private var domain: String? {
        item?.domainMetadata?.name ?? item?.domain
    }

    private var timeToRead: String? {
        item
            .flatMap { $0.timeToRead > 0 ? $0.timeToRead : nil }
            .flatMap { "\($0) min" }
    }

    private var isFavorite: Bool {
        savedItem.isFavorite
    }

    private func track(identifier: UIContext.Identifier) {
        guard let url = savedItem.bestURL else {
            return
        }

        let contexts: [Context] = [
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }
}

extension MyListItemViewModel {
    func toggleFavorite() {
        if isFavorite {
            source.unfavorite(item: savedItem)
            track(identifier: .itemUnfavorite)
        } else {
            source.favorite(item: savedItem)
            track(identifier: .itemFavorite)
        }
    }

    func archive() {
        source.archive(item: savedItem)
        track(identifier: .itemArchive)
    }

    func delete() {
        source.delete(item: savedItem)
        track(identifier: .itemDelete)
    }

    func trackImpression() {
        guard let url = savedItem.bestURL else {
            return
        }

        let content = ContentContext(url: url)
        let impression = ImpressionEvent(component: .content, requirement: .instant)
        tracker.track(event: impression, [content])
    }
}
