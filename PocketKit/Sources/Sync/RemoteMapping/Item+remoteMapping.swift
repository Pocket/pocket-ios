// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import Apollo
import PocketGraph
import SharedPocketKit

extension Item {
    func update(remote: ItemParts, with space: Space) {
        remoteID = remote.remoteID

        givenURL = remote.givenUrl
        resolvedURL = remote.resolvedUrl
        title = remote.title
        topImageURL = (remote.topImageUrl ?? remote.collection?.imageUrl).flatMap(URL.init(string:))
        domain = remote.domain
        language = remote.language

        if let readTime = remote.timeToRead {
            timeToRead = NSNumber(value: readTime)
        } else {
            timeToRead = 0
        }

        if let words = remote.wordCount {
            wordCount = NSNumber(value: words)
        } else {
            wordCount = 0
        }

        excerpt = remote.excerpt
        datePublished = remote.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) }
        isArticle = remote.isArticle ?? false
        imageness = remote.hasImage?.rawValue
        videoness = remote.hasVideo?.rawValue

        guard let context = managedObjectContext else {
            return
        }

        if let metaParts = remote.domainMetadata?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? CDDomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        article = remote.marticle.flatMap { remoteComponents -> Article? in
            let components = remoteComponents.map(ArticleComponent.init)
            return Article(components: components)
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }
        remote.authors?.forEach { remoteAuthor in
            guard let remoteAuthor = remoteAuthor else {
                return
            }

            addToAuthors(CDAuthor(remote: remoteAuthor, context: context))
        }

        if let images = images {
            removeFromImages(images)
        }
        remote.images?.forEach { remoteImage in
            guard let remoteImage = remoteImage else {
                return
            }

            addToImages(CDImage(remote: remoteImage, context: context))
        }

        if let syndicatedArticle = remote.syndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.title = syndicatedArticle.title
        }

        if let collection = remote.collection {
            self.collection = (try? space.fetchCollection(by: collection.slug, context: context)) ??
            // it's preferable not fetch authors and stories at this time, they'll be fetched once the collection
            // is accessed from the native view
            CDCollection(context: context, slug: collection.slug, title: collection.title, authors: [], stories: [])
        }
    }

    func update(remote: PendingItemParts, with space: Space) {
        remoteID = remote.remoteID

        givenURL = remote.givenUrl
    }

    func update(from corpusItem: CorpusSlateParts.Recommendation.CorpusItem, in space: Space) {
        givenURL = corpusItem.url
        title = corpusItem.title
        topImageURL = URL(string: corpusItem.imageUrl)
        domain = corpusItem.publisher
        excerpt = corpusItem.excerpt

        guard let context = managedObjectContext else {
            return
        }

        if let topImageURL {
            addToImages(CDImage(url: topImageURL, context: context))
        }

        if let syndicatedArticle = corpusItem.target?.asSyndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.publisherName = syndicatedArticle.publisher?.name
            self.syndicatedArticle?.title = syndicatedArticle.title
            self.syndicatedArticle?.excerpt = syndicatedArticle.excerpt
            self.syndicatedArticle?.imageURL = syndicatedArticle.mainImage.flatMap(URL.init(string:))
            if let imageSrc = syndicatedArticle.mainImage {
                self.syndicatedArticle?.image = CDImage(src: imageSrc, context: context)
            }
        }

        if let slug = corpusItem.target?.asCollection?.slug {
            let collection = (try? space.fetchCollection(by: slug, context: context)) ?? CDCollection(context: context, slug: slug, title: "", authors: [], stories: [])
            collection.item = self

            if let authors = corpusItem.target?.asCollection?.authors {
                collection.updateAuthors(from: authors, in: space, context: context)
            }
            self.collection = collection
        }
    }

    func update(from storyItem: GetCollectionBySlugQuery.Data.Collection.Story.Item, in space: Space) {
        title = storyItem.title
        domain = storyItem.domain
        excerpt = storyItem.excerpt
        language = storyItem.language

        if let readTime = storyItem.timeToRead {
            timeToRead = NSNumber(value: readTime)
        } else {
            timeToRead = 0
        }

        if let words = storyItem.wordCount {
            wordCount = NSNumber(value: words)
        } else {
            wordCount = 0
        }

        datePublished = storyItem.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) }
        isArticle = storyItem.isArticle ?? false
        imageness = storyItem.hasImage?.rawValue
        videoness = storyItem.hasVideo?.rawValue

        guard let context = managedObjectContext else {
            return
        }
        if let imageUrl = storyItem.topImageUrl, let url = URL(string: imageUrl) {
            topImageURL = url
            addToImages(CDImage(url: url, context: context))
        }

        if let metaParts = storyItem.domainMetadata?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? CDDomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        article = storyItem.marticle.flatMap { remoteComponents in
            let components = remoteComponents.map(ArticleComponent.init)
            return Article(components: components)
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }
        storyItem.authors?.forEach { remoteAuthor in
            guard let remoteAuthor = remoteAuthor else {
                return
            }

            addToAuthors(CDAuthor(remote: remoteAuthor, context: context))
        }

        if let images = images {
            removeFromImages(images)
        }
        storyItem.images?.forEach { remoteImage in
            guard let remoteImage = remoteImage else {
                return
            }

            addToImages(CDImage(remote: remoteImage, context: context))
        }

        if let syndicatedArticle = storyItem.syndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.title = syndicatedArticle.title
        }
    }

    func update(from summary: CompactItem, with space: Space) {
        remoteID = summary.remoteID

        givenURL = summary.givenUrl
        resolvedURL = summary.resolvedUrl
        title = summary.title
        topImageURL = summary.topImageUrl.flatMap(URL.init(string:))
        domain = summary.domain
        language = summary.language

        if let readTime = summary.timeToRead {
            timeToRead = NSNumber(value: readTime)
        } else {
            timeToRead = 0
        }
        if let words = summary.wordCount {
            wordCount = NSNumber(value: words)
        } else {
            wordCount = 0
        }
        excerpt = summary.excerpt
        datePublished = summary.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) }
        isArticle = summary.isArticle ?? false
        imageness = summary.hasImage?.rawValue
        videoness = summary.hasVideo?.rawValue

        guard let context = managedObjectContext else {
            return
        }

        if let topImageURL {
            addToImages(CDImage(url: topImageURL, context: context))
        }

        if let metaParts = summary.domainMetadata?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? CDDomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }

        summary.authors?.forEach { remoteAuthor in
            guard let remoteAuthor = remoteAuthor else {
                return
            }

            addToAuthors(CDAuthor(remote: remoteAuthor, context: context))
        }

        if let images = images {
            removeFromImages(images)
        }

        summary.images?.forEach { remoteImage in
            guard let remoteImage = remoteImage else {
                return
            }

            addToImages(CDImage(remote: remoteImage, context: context))
        }

        if let syndicatedArticle = summary.syndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.publisherName = syndicatedArticle.publisher?.name
            self.syndicatedArticle?.title = syndicatedArticle.title
            self.syndicatedArticle?.excerpt = syndicatedArticle.excerpt
            self.syndicatedArticle?.imageURL = syndicatedArticle.mainImage.flatMap(URL.init(string:))
            if let imageSrc = syndicatedArticle.mainImage {
                self.syndicatedArticle?.image = CDImage(src: imageSrc, context: context)
            }
        }
    }
}
