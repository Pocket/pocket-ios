// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

/// Maps Collection Author coming
/// from different graphQL types onto one
protocol RemoteAuthor {
    var name: String { get }
}

extension CorpusSlateParts.Recommendation.CorpusItem.Target.AsCollection.Author: RemoteAuthor {}

extension CDCollection {
    public typealias RemoteCollection = GetCollectionBySlugQuery.Data.Collection

    func update(from remote: RemoteCollection, in space: Space, context: NSManagedObjectContext) {
        intro = remote.intro
        publishedAt = remote.publishedAt.flatMap { DateFormatter.clientAPI.date(from: $0) }
        title = remote.title
        item = try? space.fetchItem(byURL: self.collectionItemUrl, context: context)
        authors = try? NSOrderedSet(array: remote.authors.map {
            try space.fetchCollectionAuthor(by: $0.name, context: context) ?? CDCollectionAuthor(context: context, name: $0.name)
        })

        stories = try? NSOrderedSet(array: remote.stories.enumerated().map {
            let story =
            CDCollectionStory(
                context: context,
                url: $0.element.url,
                title: $0.element.title,
                excerpt: $0.element.excerpt,
                authors: try makeStoryAuthors(space: space, context: context, authors: $0.element.authors)
            )

            story.sortOrder = NSNumber(value: $0.offset + 1)
            story.publisher = $0.element.publisher
            story.imageUrl = $0.element.imageUrl
            story.collection = self
            if let remoteItem = $0.element.item {
                let item = (try? space.fetchItem(byURL: remoteItem.givenUrl, context: context)) ??
                CDItem(context: context, givenURL: remoteItem.givenUrl, remoteID: remoteItem.remoteID)
                item.update(from: remoteItem, in: space)
                item.addToCollectionStories(story)
                story.item = item
            }
            return story
        })
    }

    func updateAuthors(from remoteAuthors: [RemoteAuthor], in space: Space, context: NSManagedObjectContext) {
        authors = try? NSOrderedSet(array: remoteAuthors.map {
            try space.fetchCollectionAuthor(by: $0.name, context: context) ?? CDCollectionAuthor(context: context, name: $0.name)
        })
    }

    private func makeStoryAuthors(space: Space, context: NSManagedObjectContext, authors: [RemoteCollection.Story.Author]) throws -> NSOrderedSet {
        try NSOrderedSet(array: authors.map {
            try space.fetchCollectionAuthor(by: $0.name, context: context) ?? CDCollectionAuthor(context: context, name: $0.name)
        })
    }
}
