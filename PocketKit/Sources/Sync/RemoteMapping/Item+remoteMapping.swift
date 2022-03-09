import Foundation
import CoreData
import Apollo


extension Item {

    func update(remote: ItemParts) {
        remoteID = remote.remoteId
        givenURL = URL(string: remote.givenUrl)
        resolvedURL = remote.resolvedUrl.flatMap(URL.init)
        title = remote.title
        topImageURL = remote.topImageUrl.flatMap(URL.init)
        domain = remote.domain
        language = remote.language
        timeToRead = remote.timeToRead.flatMap(Int32.init) ?? 0
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
    }

    func update(from unmanagedItem: UnmanagedItem) {
        remoteID = unmanagedItem.id
        givenURL = unmanagedItem.givenURL
        resolvedURL = unmanagedItem.resolvedURL
        title = unmanagedItem.title
        language = unmanagedItem.language
        topImageURL = unmanagedItem.topImageURL
        timeToRead = unmanagedItem.timeToRead.flatMap(Int32.init) ?? 0
        excerpt = unmanagedItem.excerpt
        domain = unmanagedItem.domain
        article = unmanagedItem.article
        datePublished = unmanagedItem.datePublished
        imageness = unmanagedItem.hasImage.flatMap(Imageness.init)?.rawValue
        videoness = unmanagedItem.hasVideo.flatMap(Videoness.init)?.rawValue

        guard let context = managedObjectContext else {
            return
        }

        domainMetadata = unmanagedItem.domainMetadata.flatMap { remote in
            let domainMeta = DomainMetadata(context: context)
            domainMeta.name = remote.name
            domainMeta.logo = remote.logo

            return domainMeta
        }

        unmanagedItem.authors?.forEach { recAuthor in
            let author = Author(context: context)
            author.id = recAuthor.id
            author.name = recAuthor.name
            author.url = recAuthor.url
            addToAuthors(author)
        }
    }
}
