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
    var article: Article?
    var datePublished: Date?
    var domain: String?
    var excerpt: String?
    var givenURL: String
    var imageness: String?
    var isArticle: Bool?
    var language: String?
    var remoteID: String
    var resolvedURL: String?
    var shareURL: String?
    var timeToRead: Int32? = 0
    var title: String?
    var topImageURL: URL?
    var videoness: String?
    var wordCount: Int16? = 0
    @Relationship(deleteRule: .cascade)
    var authors: [Author]?
    var collection: Collection?
    var collectionStories: [CollectionStory]?
    @Relationship(deleteRule: .cascade, inverse: \DomainMetadata.item)
    var domainMetadata: DomainMetadata?
    @Relationship(deleteRule: .cascade)
    var images: [Image]?
    @Relationship(inverse: \Recommendation.item)
    var recommendation: Recommendation?
    @Relationship(inverse: \SavedItem.item)
    var savedItem: SavedItem?
    @Relationship(inverse: \SharedWithYouItem.item)
    var sharedWithYouItem: SharedWithYouItem?
    @Relationship(inverse: \SyndicatedArticle.item)
    var syndicatedArticle: SyndicatedArticle?
    public init(givenURL: String, remoteID: String) {
        self.givenURL = givenURL
        self.remoteID = remoteID
    }

// #warning("The property \"ordered\" on Item:authors is unsupported in SwiftData.")
// #warning("The property \"ordered\" on Item:images is unsupported in SwiftData.")
}
