import Sync
import UIKit


class UnsupportedComponentPresenter: ArticleComponentPresenter {
    private let mainViewModel: MainViewModel
    private let readableViewModel: ReadableViewModel?

    init(
        mainViewModel: MainViewModel,
        readableViewModel: ReadableViewModel?
    ) {
        self.mainViewModel = mainViewModel
        self.readableViewModel = readableViewModel
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: UnsupportedComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.action = { [weak self] in
            self?.handleShowInWebReaderButtonTap()
        }
        return cell
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: 86)
    }

    func clearCache() {
        // no op
    }

    private func handleShowInWebReaderButtonTap() {
        mainViewModel.presentedWebReaderURL = readableViewModel?.url
    }
}
