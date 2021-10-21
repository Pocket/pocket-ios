import Foundation
import CoreData
import Apollo


extension Item {
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter
    }

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
        datePublished = remote.datePublished.flatMap { Self.dateFormatter.date(from: $0) }

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
}
