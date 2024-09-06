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
