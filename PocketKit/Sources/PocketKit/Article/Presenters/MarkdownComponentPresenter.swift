import Foundation
import Sync
import UIKit


class MarkdownComponentPresenter: ArticleComponentPresenter {
    private let component: MarkdownComponent
    
    private let readerSettings: ReaderSettings
    
    private lazy var content: NSAttributedString? = {
        NSAttributedString.styled(
          markdown: component.content,
          styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )
    }()
    
    init(component: MarkdownComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        content.flatMap {
            let height = $0.sizeFitting(availableWidth: availableWidth).height
            + MarkdownComponentCell.Constants.layoutMargins.bottom

            return CGSize(width: availableWidth, height: height)
        } ?? .zero
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.attributedContent = content
        return cell
    }
}
