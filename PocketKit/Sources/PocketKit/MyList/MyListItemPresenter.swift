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
}

protocol MyListItemDomainMetadata {
    var name: String? { get }
}

protocol MyListItem {
    var title: String? { get }
    var isFavorite: Bool { get }
    var bestURL: URL? { get }
    var topImageURL: URL? { get }
    var domain: String? { get }

    var domainMetadata: MyListItemDomainMetadata? { get }
    var timeToRead: Int? { get }
}

class MyListItemPresenter {
    private let item: MyListItem

    init(item: MyListItem) {
        self.item = item
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: .title)
    }

    var attributedDetail: NSAttributedString {
        NSAttributedString(string: detail, style: .detail)
    }

    var thumbnailURL: URL? {
        return imageCacheURL(for: item.topImageURL)
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

    private var title: String {
        [
            item.title,
            item.bestURL?.absoluteString
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
        item.domainMetadata?.name ?? item.domain
    }

    private var timeToRead: String? {
        item.timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { "\($0) min" }
    }

    private var isFavorite: Bool {
        item.isFavorite
    }
}

extension SavedItem: MyListItem {
    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item.flatMap { Int($0.timeToRead) }
    }

    var domainMetadata: MyListItemDomainMetadata? {
        return item?.domainMetadata
    }
}

extension DomainMetadata: MyListItemDomainMetadata {

}

extension ArchivedItem: MyListItem {
    var title: String? {
        item?.title
    }

    var bestURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var domain: String? {
        item?.domain
    }

    var domainMetadata: MyListItemDomainMetadata? {
        item?.domainMetadata
    }

    var timeToRead: Int? {
        item?.timeToRead
    }
}

extension UnmanagedItem.DomainMetadata: MyListItemDomainMetadata {

}
