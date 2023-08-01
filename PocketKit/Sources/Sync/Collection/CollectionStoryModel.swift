// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct CollectionStoryModel: Equatable, Hashable {
    public init(url: String, title: String, publisher: String?, imageURL: String?, excerpt: Markdown, timeToRead: Int?, isCollection: Bool, item: Item?) {
        self.url = url
        self.title = title
        self.publisher = publisher
        self.imageURL = imageURL
        self.excerpt = excerpt
        self.timeToRead = timeToRead
        self.isCollection = isCollection
        self.item = item
    }

    public let url: String
    public let title: String
    public let publisher: String?
    public let imageURL: String?
    public let excerpt: Markdown
    public let timeToRead: Int?
    public let item: Item?
    public let isCollection: Bool
}
