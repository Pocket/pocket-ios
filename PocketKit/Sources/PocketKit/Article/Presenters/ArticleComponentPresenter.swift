import UIKit


protocol ArticleComponentPresenter {
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell
    func size(for availableWidth: CGFloat) -> CGSize
}
