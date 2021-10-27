import UIKit
import Sync
import Textile


private extension Style {
    static let title: Style = .header.sansSerif.h5.with { $0.with(alignment: .center) }
    static let byline: Style = .header.sansSerif.p3.with {
        $0.with(alignment: .center)
        .with(lineSpacing: 6)
    }
    static let authorName: Style = .header.sansSerif.h7
}


struct ReadablePresenter {
    private let readable: Readable

    init(readable: Readable) {
        self.readable = readable
    }

    var attributedTitle: NSAttributedString? {
        guard let title = readable.title else {
            return nil
        }

        return NSAttributedString(title, style: .title)
    }

    var attributedByline: NSAttributedString? {
        let byline = NSMutableAttributedString("", style: .byline)

        if let authors = readable.authors, !authors.isEmpty {
            let authorNames = authors.compactMap { $0.name }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString

            let attributedAuthorNames = NSMutableAttributedString(authorNamesString as String, style: .byline)
            authorNames.forEach { name in
                attributedAuthorNames.setAttributes(
                    Style.authorName.textAttributes,
                    range: authorNamesString.range(of: name)
                )
            }

            byline.append(NSAttributedString("by ", style: .byline))
            byline.append(attributedAuthorNames)
        }

        if let domain = readable.domain {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(", ", style: .byline))
            }

            byline.append(NSAttributedString(domain, style: .byline))
        }

        if let datePublished = readable.publishDate {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString("\n", style: .byline))
            }

            let dateString = datePublished.formatted(date: .long, time: .omitted)
            byline.append(NSAttributedString(dateString, style: .byline))
        }

        return byline
    }

    var attributedDomain: NSAttributedString? {
        readable.domain.flatMap {
            NSAttributedString($0, style: .byline)
        }
    }
}
