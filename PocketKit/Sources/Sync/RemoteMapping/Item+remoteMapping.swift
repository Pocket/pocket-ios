import Foundation
import CoreData
import Apollo
import PocketGraph

extension Item {
    func update(remote: ItemParts, with space: Space) {
        remoteID = remote.remoteID

        guard let url = URL(string: remote.givenUrl) else {
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of Item \(remoteID) because \(givenURL) is not valid url")
            return
        }

        givenURL = url
        resolvedURL = remote.resolvedUrl.flatMap(URL.init)
        title = remote.title
        topImageURL = remote.topImageUrl.flatMap(URL.init)
        domain = remote.domain
        language = remote.language

        if let readTime = remote.timeToRead {
            timeToRead = NSNumber(value: readTime)
        } else {
            timeToRead = 0
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
            domainMetadata = domainMetadata ?? DomainMetadata(context: context)
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

            addToAuthors(Author(remote: remoteAuthor, context: context))
        }

        if let images = images {
            removeFromImages(images)
        }
        remote.images?.forEach { remoteImage in
            guard let remoteImage = remoteImage else {
                return
            }

            addToImages(Image(remote: remoteImage, context: context))
        }

        if let syndicatedArticle = remote.syndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
        }
    }

    func update(from summary: ItemSummary, with space: Space) {
        remoteID = summary.remoteID

        guard let url = URL(string: summary.givenUrl) else {
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of Item \(remoteID) because \(summary.givenUrl) is not valid url")
            return
        }

        givenURL = url
        resolvedURL = summary.resolvedUrl.flatMap(URL.init)
        title = summary.title
        topImageURL = summary.topImageUrl.flatMap(URL.init)
        domain = summary.domain
        language = summary.language
        if let readTime = summary.timeToRead {
            timeToRead = NSNumber(value: readTime)
        } else {
            timeToRead = 0
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
            addToImages(Image(url: topImageURL, context: context))
        }

        if let metaParts = summary.domainMetadata?.fragments.domainMetadataParts {
            domainMetadata = domainMetadata ?? DomainMetadata(context: context)
            domainMetadata?.update(remote: metaParts)
        }

        if let authors = authors {
            removeFromAuthors(authors)
        }

        summary.authors?.forEach { remoteAuthor in
            guard let remoteAuthor = remoteAuthor else {
                return
            }

            addToAuthors(Author(remote: remoteAuthor, context: context))
        }

        if let images = images {
            removeFromImages(images)
        }

        summary.images?.forEach { remoteImage in
            guard let remoteImage = remoteImage else {
                return
            }

            addToImages(Image(remote: remoteImage, context: context))
        }

        if let syndicatedArticle = summary.syndicatedArticle, let itemId = syndicatedArticle.itemId {
            self.syndicatedArticle = (try? space.fetchSyndicatedArticle(byItemId: itemId, context: context)) ?? SyndicatedArticle(context: context)
            self.syndicatedArticle?.itemID = itemId
            self.syndicatedArticle?.publisherName = syndicatedArticle.publisher?.name
            self.syndicatedArticle?.title = syndicatedArticle.title
            self.syndicatedArticle?.excerpt = syndicatedArticle.excerpt
            self.syndicatedArticle?.imageURL = syndicatedArticle.mainImage.flatMap(URL.init)
            if let imageSrc = syndicatedArticle.mainImage {
                self.syndicatedArticle?.image = Image(src: imageSrc, context: context)
            }
        }
    }
}
