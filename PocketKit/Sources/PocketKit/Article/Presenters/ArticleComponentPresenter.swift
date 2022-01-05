import UIKit


protocol ArticleComponentPresenter {
    @MainActor
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell
    func size(for availableWidth: CGFloat) -> CGSize
    func clearCache()
}
