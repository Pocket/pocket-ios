// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit

class UnsupportedComponentPresenter: ArticleComponentPresenter {
    var componentIndex: Int

    var highlightIndexes: [Int]?

    private let readableViewModel: ReadableViewModel?

    init(readableViewModel: ReadableViewModel?, componentIndex: Int) {
        self.readableViewModel = readableViewModel
        self.componentIndex = componentIndex
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, onHighlight: ((Int, NSRange) -> Void)?) -> UICollectionViewCell {
        let cell: UnsupportedComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.action = { [weak self] in
            self?.handleShowInWebReaderButtonTap()
        }
        readableViewModel?.trackUnsupportedContentViewed()
        return cell
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: 86)
    }

    func clearCache() {
        // no op
    }

    func loadContent() {
        // no op
    }

    private func handleShowInWebReaderButtonTap() {
        readableViewModel?.showWebReader()
        readableViewModel?.trackUnsupportedContentButtonTapped()
    }
}
