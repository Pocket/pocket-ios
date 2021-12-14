import Sync
import UIKit


class DividerComponentPresenter: ArticleComponentPresenter {
    private let component: DividerComponent
    
    init(component: DividerComponent) {
        self.component = component
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: 16)
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: DividerComponentCell = collectionView.dequeueCell(for: indexPath)
        return cell
    }
}
