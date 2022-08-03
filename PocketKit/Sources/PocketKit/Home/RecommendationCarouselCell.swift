import Foundation
import UIKit
import Textile


class RecommendationCarouselCell: HomeCarouselItemCell {
    struct Model: HomeCarouselItemCellModel {
        private let viewModel: HomeRecommendationCellViewModel

        init(viewModel: HomeRecommendationCellViewModel) {
            self.viewModel = viewModel
        }

        var favoriteAction: ItemAction? {
            // Recommendations can't be favorited
            return nil
        }

        var thumbnailURL: URL? {
            viewModel.imageURL
        }

        var saveButtonMode: RecommendationSaveButton.Mode? {
            viewModel.saveButtonMode
        }

        var overflowActions: [ItemAction]? {
            viewModel.overflowActions
        }

        var saveAction: ItemAction? {
            viewModel.primaryAction
        }

        var attributedTitle: NSAttributedString {
            return NSAttributedString(string: viewModel.title ?? "", style: .title)
        }
        
        var attributedDomain: NSAttributedString {
            return NSAttributedString(string: viewModel.domain ?? "", style: .domain)
        }
        
        var attributedTimeToRead: NSAttributedString {
            return NSAttributedString(string: viewModel.timeToRead ?? "", style: .timeToRead)
        }
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with { paragraph in
        paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
    
    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
