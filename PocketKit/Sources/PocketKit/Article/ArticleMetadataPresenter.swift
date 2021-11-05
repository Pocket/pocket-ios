import UIKit
import Sync
import Textile


private extension Style {
    static func title(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .h5
        .with { $0.with(alignment: .center) }
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }

    static func byline(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p3
        .with {
            $0.with(alignment: .center).with(lineSpacing: 6)
        }
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }

    static func authorName(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .h7
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }
    
    static func standardText(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p2
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }
}

struct ArticleMetadataPresenter {
    private let readable: Readable
    private let readerSettings: ReaderSettings

    init(readable: Readable, readerSettings: ReaderSettings) {
        self.readable = readable
        self.readerSettings = readerSettings
    }

    var attributedTitle: NSAttributedString? {
        guard let title = readable.title else {
            return nil
        }

        return NSAttributedString(string: title, style: .title(modifier: readerSettings))
    }

    var attributedByline: NSAttributedString? {
        let byline = NSMutableAttributedString(string: "", style: .byline(modifier: readerSettings))

        if let authors = readable.authors, !authors.isEmpty {
            let authorNames = authors.compactMap { $0.name }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString

            let attributedAuthorNames = NSMutableAttributedString(string: authorNamesString as String, style: .byline(modifier: readerSettings))
            authorNames.forEach { name in
                attributedAuthorNames.setAttributes(
                    Style.authorName(modifier: readerSettings).textAttributes,
                    range: authorNamesString.range(of: name)
                )
            }

            byline.append(NSAttributedString(string: "by ", style: .byline(modifier: readerSettings)))
            byline.append(attributedAuthorNames)
        }

        if let domain = readable.domain {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: ", ", style: .byline(modifier: readerSettings)))
            }

            byline.append(NSAttributedString(string: domain, style: .byline(modifier: readerSettings)))
        }

        if let datePublished = readable.publishDate {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: "\n", style: .byline(modifier: readerSettings)))
            }

            let dateString = datePublished.formatted(date: .long, time: .omitted)
            byline.append(NSAttributedString(string: dateString, style: .byline(modifier: readerSettings)))
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
            NSAttributedString(string: $0, style: .byline(modifier: readerSettings))
        }
    }
}
