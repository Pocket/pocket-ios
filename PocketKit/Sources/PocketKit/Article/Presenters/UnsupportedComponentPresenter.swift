import Sync
import UIKit


class UnsupportedComponentPresenter: ArticleComponentPresenter {    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: UnsupportedComponentCell = collectionView.dequeueCell(for: indexPath)
        return cell
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: 86)
    }

    func clearCache() {
        // no op
    }
}
