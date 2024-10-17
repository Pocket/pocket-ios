// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import Apollo
import PocketGraph
import SharedPocketKit

extension CDItem {
    /// Update an equatable value only if different from the existing, to minimize object updates that translate into model changes and view updates
    ///  courtssy of https://forums.swift.org/t/assign-if-different/61168/18
    /// - Parameters:
    ///   - path: keypath to the property to update
    ///   - newValue: proposed value
    public func updateIfNotEqual<T: Equatable>(
        _ path: ReferenceWritableKeyPath<CDItem, T>,
        _ newValue: T
    ) {
        if self[keyPath: path] != newValue {
            self[keyPath: path] = newValue
        }
    }
}

extension CDItem {
    func updateIfNeeded(remote: ItemParts, with space: Space) {
        updateIfNotEqual(\.remoteID, remote.remoteID)
        updateIfNotEqual(\.givenURL, remote.givenUrl)
        updateIfNotEqual(\.resolvedURL, remote.resolvedUrl)
        updateIfNotEqual(\.title, remote.preview?.title)
        if let imageUrl = (remote.preview?.image?.url ?? remote.collection?.imageUrl).flatMap(URL.init(string:)) {
            updateIfNotEqual(\.topImageURL, imageUrl)
        }
        updateIfNotEqual(\.domain, remote.preview?.domain?.name)
        updateIfNotEqual(\.language, remote.language)

        if let readTime = remote.timeToRead {
            updateIfNotEqual(\.timeToRead, NSNumber(value: readTime))
        }

        if let words = remote.wordCount {
            updateIfNotEqual(\.wordCount, NSNumber(value: words))
        }

        updateIfNotEqual(\.excerpt, remote.preview?.excerpt)
        updateIfNotEqual(\.datePublished, remote.preview?.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) })
        updateIfNotEqual(\.isArticle, remote.isArticle ?? false)
        updateIfNotEqual(\.imageness, remote.hasImage?.rawValue)
        updateIfNotEqual(\.videoness, remote.hasVideo?.rawValue)

        guard let context = managedObjectContext else {
            return
        }

        if let metaParts = remote.preview?.domain?.fragments.domainMetadataParts {
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
        remote.preview?.authors?.forEach { remoteAuthor in
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
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? CDSyndicatedArticle(context: context)
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
        title = corpusItem.preview.title
        if let timeToRead = corpusItem.timeToRead {
            self.timeToRead = NSNumber(value: timeToRead)
        }
        // TODO: PREVIEW - after a bit of testing, we should remove the option of using corpusItem.imageUrl
        topImageURL = URL(string: corpusItem.preview.image?.url ?? corpusItem.imageUrl)
        domain = corpusItem.preview.domain?.name
        excerpt = corpusItem.preview.excerpt

        guard let context = managedObjectContext else {
            return
        }

        if let topImageURL {
            addToImages(CDImage(url: topImageURL, context: context))
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }
        corpusItem.preview.authors?.forEach { remoteAuthor in
           addToAuthors(CDAuthor(remote: remoteAuthor, context: context))
        }

        if let metaParts = corpusItem.preview.domain?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? CDDomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        if let syndicatedArticle = corpusItem.target?.asSyndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? CDSyndicatedArticle(context: context)
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
        title = storyItem.preview?.title
        domain = storyItem.preview?.domain?.name
        excerpt = storyItem.preview?.excerpt
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

        datePublished = storyItem.preview?.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) }
        isArticle = storyItem.isArticle ?? false
        imageness = storyItem.hasImage?.rawValue
        videoness = storyItem.hasVideo?.rawValue

        guard let context = managedObjectContext else {
            return
        }
        if let imageUrl = storyItem.preview?.image?.url, let url = URL(string: imageUrl) {
            topImageURL = url
            addToImages(CDImage(url: url, context: context))
        }

        if let metaParts = storyItem.preview?.domain?.fragments.domainMetadataParts {
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
        storyItem.preview?.authors?.forEach { remoteAuthor in
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
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? CDSyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.title = syndicatedArticle.title
        }
    }

    func update(from summary: CompactItem, with space: Space) {
        remoteID = summary.remoteID

        givenURL = summary.givenUrl
        resolvedURL = summary.resolvedUrl
        title = summary.preview?.title
        if let urlString = summary.preview?.image?.url {
            topImageURL = URL(string: urlString)
        }
        domain = summary.preview?.domain?.name
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
        excerpt = summary.preview?.excerpt
        datePublished = summary.preview?.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) }
        isArticle = summary.isArticle ?? false
        imageness = summary.hasImage?.rawValue
        videoness = summary.hasVideo?.rawValue

        guard let context = managedObjectContext else {
            return
        }

        if let topImageURL {
            addToImages(CDImage(url: topImageURL, context: context))
        }

        if let metaParts = summary.preview?.domain?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? CDDomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }

        summary.preview?.authors?.forEach { remoteAuthor in
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
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? CDSyndicatedArticle(context: context)
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
