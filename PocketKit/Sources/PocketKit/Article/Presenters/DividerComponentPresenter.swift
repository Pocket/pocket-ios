import Sync
import UIKit


class DividerComponentPresenter: ArticleComponentPresenter {
    private let component: DividerComponent
    
    init(component: DividerComponent) {
        self.component = component
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: 32 + DividerComponentCell.Constants.dividerHeight)
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: DividerComponentCell = collectionView.dequeueCell(for: indexPath)
        return cell
    }

    func clearCache() {
        // no op
    }
}
