import UIKit
import Sync
import Textile


private extension Style {
    static func title(modifier: StylerModifier) -> Style {
        .header
        .serif
        .title
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.925))
        }
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }

    static func byline(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p4
        .with(weight: .medium)
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }
        .adjustingSize(by: modifier.fontSizeAdjustment)
    }

    static func publishedDate(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p4
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }
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
        let byline = NSMutableAttributedString()
        let style = Style.byline(modifier: readerSettings)

        if let authors = readable.authors, !authors.isEmpty {
            let authorNames = authors.compactMap { $0.name }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString
            let attributedAuthorNames = NSMutableAttributedString(string: authorNamesString as String, style: style)

            byline.append(attributedAuthorNames)
        }

        if let domain = readable.domain {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: " • ", style: style))
            }

            byline.append(NSAttributedString(string: domain, style: .byline(modifier: readerSettings)))
        }

        return byline
    }

    var attributedPublishedDate: NSAttributedString? {
        readable.publishDate
            .flatMap { $0.formatted(date: .long, time: .omitted) }
            .flatMap { NSAttributedString(string: $0, style: .publishedDate(modifier: readerSettings)) }
    }

    func size(for availableItemWidth: CGFloat) -> CGSize {
        var height: CGFloat = 0

        if let byline = attributedByline {
            height += Self.height(of: byline, width: availableItemWidth)
        }

        if let publishedDate = attributedPublishedDate {
            height += Self.height(of: publishedDate, width: availableItemWidth)
        }

        if let title = attributedTitle {
            if height > 0 {
                height += ArticleMetadataCell.Constants.stackSpacing
            }

            height += Self.height(of: title, width: availableItemWidth)
        }

        height += ArticleMetadataCell.Constants.layoutMargins.bottom

        return CGSize(
            width: availableItemWidth,
            height: height
        )
    }

    private static func height(of attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
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
