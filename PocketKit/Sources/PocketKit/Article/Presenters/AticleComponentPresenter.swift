import UIKit


protocol ArticleComponentPresenter {
    var size: CGSize { get }
    func cell(for indexPath: IndexPath) -> UICollectionViewCell
}
