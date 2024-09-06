// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Item {
    // #Unique<Item>([\.givenURL])
    @Attribute(.transformable(by: ArticleTransformer.self))
    public var article: Article?
    public var datePublished: Date?
    public var domain: String?
    public var excerpt: String?
    public var givenURL: String
    public var imageness: String?
    public var isArticle: Bool?
    public var language: String?
    public var remoteID: String
    public var resolvedURL: String?
    public var shareURL: String?
    public var timeToRead: Int32? = 0
    public var title: String?
    public var topImageURL: URL?
    public var videoness: String?
    public var wordCount: Int16? = 0
    @Relationship(deleteRule: .cascade)
    public var authors: [Author]?
    public var collection: Collection?
    public var collectionStories: [CollectionStory]?
    @Relationship(deleteRule: .cascade, inverse: \DomainMetadata.item)
    public var domainMetadata: DomainMetadata?
    @Relationship(deleteRule: .cascade)
    public var images: [Image]?
    @Relationship(inverse: \Recommendation.item)
    public var recommendation: Recommendation?
    @Relationship(inverse: \SavedItem.item)
    public var savedItem: SavedItem?
    @Relationship(inverse: \SharedWithYouItem.item)
    public var sharedWithYouItem: SharedWithYouItem?
    @Relationship(inverse: \SyndicatedArticle.item)
    public var syndicatedArticle: SyndicatedArticle?
    public init(givenURL: String, remoteID: String) {
        self.givenURL = givenURL
        self.remoteID = remoteID
    }

// #warning("The property \"ordered\" on Item:authors is unsupported in SwiftData.")
// #warning("The property \"ordered\" on Item:images is unsupported in SwiftData.")
}

// MARK: Helpers
extension Item {
    public var bestURL: String {
        resolvedURL ?? givenURL
    }

    public var hasImage: ItemImageness? {
        imageness.flatMap(ItemImageness.init)
    }

    public var hasVideo: ItemVideoness? {
        videoness.flatMap(ItemVideoness.init)
    }

    public func shouldOpenInWebView(override: Bool) -> Bool {
        if override == true {
            return true
        }

        if isSyndicated {
            return false
        }

        if isSaved {
            // We are legally allowed to open the item in reader view
            // BUT: if any of the following are true...
            // a) the item is not an article (i.e. it was not parseable)
            // b) the item is an image
            // c) the item is a video
            if isArticle == false || isImage || isVideo {
                // then we should open in web view
                return true
            } else {
                // the item is safe to open in reader view
                return false
            }
        } else {
            // We are not legally allowed to open the item in reader view
            // open in web view
            return true
        }
    }

    public var isSyndicated: Bool {
        syndicatedArticle != nil
    }

    public var isSaved: Bool {
        savedItem != nil
    }

    var isVideo: Bool {
        hasVideo == .isVideo
    }

    var isImage: Bool {
        hasImage == .isImage
    }

    var hasArticleComponents: Bool {
        article?.components.isEmpty == false
    }

    var isCollection: Bool {
        CollectionUrlFormatter.isCollectionUrl(givenURL)
    }

    var collectionSlug: String? {
        CollectionUrlFormatter.slug(from: givenURL)
    }

    var bestDomain: String? {
        syndicatedArticle?.publisherName
        ?? domainMetadata?.name
        ?? domain
        ?? URL(percentEncoding: bestURL)?.host
    }
}
