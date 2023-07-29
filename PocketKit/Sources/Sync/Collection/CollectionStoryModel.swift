// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct StoryModel: Equatable, Hashable {
    public init(title: String, publisher: String?, imageURL: String?, excerpt: Markdown, timeToRead: Int?, isCollection: Bool) {
        self.title = title
        self.publisher = publisher
        self.imageURL = imageURL
        self.excerpt = excerpt
        self.timeToRead = timeToRead
        self.isCollection = isCollection
    }

    public let title: String
    public let publisher: String?
    public let imageURL: String?
    public let excerpt: Markdown
    public let timeToRead: Int?
    public let isCollection: Bool
}
