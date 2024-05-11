// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile

private extension Style {
    static func title(modifier: StylerModifier) -> Style {
        var style: Style = .header
            .serif
            .title
            .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.925))
            }

        if modifier.fontFamily == .graphik {
            style = style.with(weight: .medium)
        }

        return style.modified(by: modifier)
    }

    static func byline(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p4
        .with(weight: .medium)
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }
        .modified(by: modifier)
    }

    static func publishedDate(modifier: StylerModifier) -> Style {
        .header
        .sansSerif
        .p4
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }
        .modified(by: modifier)
    }
}

@MainActor
struct ArticleMetadataPresenter {
    private let readableViewModel: ReadableViewModel
    private let readerSettings: ReaderSettings

    init(readableViewModel: ReadableViewModel, readerSettings: ReaderSettings) {
        self.readableViewModel = readableViewModel
        self.readerSettings = readerSettings
    }

    var attributedTitle: NSAttributedString? {
        guard let title = readableViewModel.title else {
            return nil
        }

        return NSAttributedString(string: title, style: .title(modifier: readerSettings))
    }

    var attributedByline: NSAttributedString? {
        let byline = NSMutableAttributedString()
        let style = Style.byline(modifier: readerSettings)

        if let authors = readableViewModel.authors, !authors.isEmpty {
            let authorNames = authors.compactMap { $0.name }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString
            let attributedAuthorNames = NSMutableAttributedString(string: authorNamesString as String, style: style)

            byline.append(attributedAuthorNames)
        }

        if let domain = readableViewModel.domain {
            if !byline.string.isEmpty {
                byline.append(NSAttributedString(string: " • ", style: style))
            }

            byline.append(NSAttributedString(string: domain, style: style))
        }

        return byline
    }

    var attributedPublishedDate: NSAttributedString? {
        readableViewModel.publishDate
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
