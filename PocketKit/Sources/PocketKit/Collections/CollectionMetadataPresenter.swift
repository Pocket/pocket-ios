// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Textile
import Localization
import Down

// Contains logic to present metadata for a collection such as title, excerpt, stories count
struct CollectionMetadataPresenter {
    private let collectionViewModel: CollectionViewModel

    init(collectionViewModel: CollectionViewModel) {
        self.collectionViewModel = collectionViewModel
    }

    var attributedByline: NSAttributedString? {
        let byline = NSMutableAttributedString()

        byline.append(NSAttributedString(string: Localization.Collection.title, style: .collection.collection))

        if !byline.string.isEmpty {
            byline.append(NSAttributedString(string: " • ", style: .collection.authors))
        }

        let authors = collectionViewModel.authors
        if !authors.isEmpty {
            let authorNames = authors.compactMap { $0 }
            let authorNamesString = ListFormatter.localizedString(byJoining: authorNames) as NSString
            let attributedAuthorNames = NSMutableAttributedString(string: authorNamesString as String, style: .collection.authors)

            byline.append(attributedAuthorNames)
        }
        return byline
    }

    var attributedTitle: NSAttributedString? {
        return NSAttributedString(string: collectionViewModel.title, style: .collection.title)
    }

    var attributedCount: NSAttributedString? {
        guard let count = collectionViewModel.storiesCount else { return nil }

        return NSAttributedString(string: Localization.Collection.Stories.count(count), style: .collection.detail)
    }

    var attributedIntro: NSAttributedString? {
        guard let intro = collectionViewModel.intro,
              let str = NSAttributedString.styled(
                markdown: intro,
                styler: NSMutableAttributedString.collectionStyler(bodyStyle: .collection.intro)
              )
        else {
            return nil
        }
        let mutable = NSMutableAttributedString(attributedString: str)
        // Down seems to be replacing double newline characters with paragraph separators, so we are reversing that here
        // https://github.com/johnxnguyen/Down/issues/269
        mutable.mutableString.replaceOccurrences(of: "\u{2029}", with: "\n\n", range: NSRange(location: 0, length: mutable.string.count))
        return mutable
    }

    /// Calculates the size of the section for the collection metadata
    /// - Parameter availableItemWidth: width that the section takes
    /// - Returns: height to be used in calculating section height
    func size(for availableItemWidth: CGFloat) -> CGSize {
        var height: CGFloat = 0

        if let byline = attributedByline {
            height += Self.height(of: byline, width: availableItemWidth)
        }

        if let itemCount = attributedCount {
            height += Self.height(of: itemCount, width: availableItemWidth)
        }

        if let title = attributedTitle {
            if height > 0 {
                height += CollectionMetadataCell.Constants.stackSpacing
            }

            height += Self.height(of: title, width: availableItemWidth)
        }

        if let intro = attributedIntro {
            if height > 0 {
                height += CollectionMetadataCell.Constants.stackSpacing
            }
            height += Self.height(of: intro, width: availableItemWidth)
        }

        height += CollectionMetadataCell.Constants.layoutMargins.bottom

        return CGSize(
            width: availableItemWidth,
            height: height
        )
    }

    /// Helper method that calculates the height of an attributed string
    /// - Parameters:
    ///   - attributedString: string that will be used to determine how much height it occupies
    ///   - width: available width that the string will occupy
    /// - Returns: calculated height that the string will take up based on width and attributed string
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
