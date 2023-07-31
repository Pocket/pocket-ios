// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

extension Collection {
    public typealias RemoteCollection = GetCollectionBySlugQuery.Data.Collection

    func update(from remote: RemoteCollection, in space: Space, context: NSManagedObjectContext) {
        intro = remote.intro
        publishedAt = remote.publishedAt.flatMap { DateFormatter.clientAPI.date(from: $0) }
        title = remote.title

        authors = try? NSOrderedSet(array: remote.authors.map {
            try space.fetchCollectionAuthor(by: $0.name, context: context) ?? CollectionAuthor(context: context, name: $0.name)
        })

        stories = try? NSOrderedSet(array: remote.stories.enumerated().map {
            let story = try space.fetchCollectionStory(by: $0.element.url, context: context) ??
            CollectionStory(
                context: context,
                url: $0.element.url,
                title: $0.element.title,
                excerpt: $0.element.excerpt,
                authors: makeStoryAuthors(space: space, context: context, authors: $0.element.authors)
            )

            story.sortOrder = NSNumber(value: $0.offset + 1)
            if let remoteItem = $0.element.item {
                let item = (try? space.fetchItem(byURL: remoteItem.givenUrl, context: context)) ??
                Item(context: context, givenURL: remoteItem.givenUrl, remoteID: remoteItem.remoteID)
                item.update(from: remoteItem, in: space)
                story.item = item
            }
            return story
        })
    }

    private func makeStoryAuthors(space: Space, context: NSManagedObjectContext, authors: [RemoteCollection.Story.Author]) throws -> NSOrderedSet {
        try NSOrderedSet(array: authors.map {
            try space.fetchCollectionAuthor(by: $0.name, context: context) ?? CollectionAuthor(context: context, name: $0.name)
        })
    }
}
