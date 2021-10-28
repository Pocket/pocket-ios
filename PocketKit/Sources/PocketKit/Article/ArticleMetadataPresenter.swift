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
    static let standardText: Style = .header.sansSerif.p2
}

struct ArticleMetadataPresenter {
    private let readable: Readable

    init(readable: Readable) {
        self.readable = readable
    }

    var attributedTitle: NSAttributedString? {
        guard let title = readable.title else {
            return nil
        }

        return NSAttributedString(string: title, style: .title)
    }

    var attributedByline: NSAttributedString? {
        let byline = NSMutableAttributedString(string: "", style: .byline)

        if let authors = readable.authors, !authors.isEmpty {
            let authorNames = authors.compactMap { $0.name }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString

            let attributedAuthorNames = NSMutableAttributedString(string: authorNamesString as String, style: .byline)
            authorNames.forEach { name in
                attributedAuthorNames.setAttributes(
                    Style.authorName.textAttributes,
                    range: authorNamesString.range(of: name)
                )
            }

            byline.append(NSAttributedString(string: "by ", style: .byline))
            byline.append(attributedAuthorNames)
        }

        if let domain = readable.domain {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: ", ", style: .byline))
            }

            byline.append(NSAttributedString(string: domain, style: .byline))
        }

        if let datePublished = readable.publishDate {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: "\n", style: .byline))
            }

            let dateString = datePublished.formatted(date: .long, time: .omitted)
            byline.append(NSAttributedString(string: dateString, style: .byline))
        }

        return byline
    }

    func size(for availableItemWidth: CGFloat) -> CGSize {
        var height: CGFloat = 0

        if let title = attributedTitle {
            height += Self.height(
                of: title,
                width: availableItemWidth
            )
        }

        if let byline = attributedByline {
            height += Self.height(
                of: byline,
                width: availableItemWidth
            )
        }

        return CGSize(
            width: availableItemWidth,
            height: height
            + ArticleMetadataCell.Constants.stackSpacing
        )
    }

    static func height(of attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
        guard !attributedString.string.isEmpty else {
            return 0
        }

        let rect = attributedString.boundingRect(
            with: CGSize(width: width, height: .infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        )

        return rect.height.rounded(.up)
    }
}

extension ArticleMetadataPresenter {
    private var attributedDomain: NSAttributedString? {
        readable.domain.flatMap {
            NSAttributedString(string: $0, style: .byline)
        }
    }
}
