// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Textile
import Localization

struct RecommendationCellConfiguration: HomeCarouselCellConfiguration {
    private let viewModel: HomeItemCellViewModel

    init(viewModel: HomeItemCellViewModel) {
        self.viewModel = viewModel
    }

    var favoriteAction: ItemAction? {
        // Recommendations can't be favorited
        return nil
    }

    var thumbnailURL: URL? {
        viewModel.imageURL
    }

    var saveButtonMode: ItemCellSaveButton.Mode? {
        viewModel.saveButtonMode
    }

    var overflowActions: [ItemAction]? {
        viewModel.overflowActions
    }

    var saveAction: ItemAction? {
        viewModel.primaryAction
    }

    var attributedCollection: NSAttributedString? {
        guard viewModel.item.isCollection else { return nil }
        return NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        return NSAttributedString(string: viewModel.title ?? "", style: .recommendation.title)
    }

    var attributedDomain: NSAttributedString {
        let detailString = NSMutableAttributedString(string: viewModel.domain ?? "", style: .recommendation.domain)
        return viewModel.item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString
    }

    var attributedTimeToRead: NSAttributedString {
        return NSAttributedString(string: viewModel.timeToRead ?? "", style: .recommendation.timeToRead)
    }

    var sharedWithYouUrlString: String? {
        nil
    }
}
