// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph
import Textile
import Localization
import Sync

// Contains logic to present story data in RecommendationCell
struct CollectionStoryViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(storyModel)
    }

    public static func == (lhs: CollectionStoryViewModel, rhs: CollectionStoryViewModel) -> Bool {
        return lhs.storyModel == rhs.storyModel
    }

    private let storyModel: CollectionStoryModel

    init(storyModel: CollectionStoryModel) {
        self.storyModel = storyModel
    }
}

extension CollectionStoryViewModel: RecommendationCellViewModel {
    var attributedCollection: NSAttributedString? {
        guard storyModel.isCollection else { return nil }
        return NSAttributedString(string: Localization.Collection.title, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title ?? "", style: .recommendation.title)
    }

    var attributedDomain: NSAttributedString {
        NSAttributedString(string: domain ?? "", style: .recommendation.domain)
    }

    var attributedExcerpt: NSAttributedString? {
        guard let str = NSAttributedString.styled(
                markdown: excerpt,
                styler: NSMutableAttributedString.collectionStyler(bodyStyle: .recommendation.excerpt)
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

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .recommendation.timeToRead)
    }

    var title: String? {
        storyModel.title
    }

    var imageURL: URL? {
        guard let imageURL = storyModel.imageURL else { return nil }
        return URL(string: imageURL)
    }

    var saveButtonMode: RecommendationSaveButton.Mode {
        .save
    }

    var excerpt: Markdown {
        storyModel.excerpt
    }

    var domain: String? {
        storyModel.publisher
    }

    var timeToRead: String? {
        guard let timeToRead = storyModel.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return Localization.Home.Recommendation.readTime(timeToRead)
    }

    var overflowActions: [ItemAction]? {
        return nil
    }

    var primaryAction: ItemAction? {
        return nil
    }
}