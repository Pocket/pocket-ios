// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct CollectionModel: Equatable, Hashable {
    public let title: String
    public let authors: [String]
    public let intro: Markdown?
    public let stories: [Story]

    public init(title: String, authors: [String], intro: Markdown?, stories: [Story]) {
        self.title = title
        self.authors = authors
        self.intro = intro
        self.stories = stories
    }
}

public struct Story: Equatable, Hashable {
    public let title: String
    public let publisher: String?
    public let imageURL: String?
    public let excerpt: Markdown
    public let timeToRead: Int?
    public let isCollection: Bool
}
