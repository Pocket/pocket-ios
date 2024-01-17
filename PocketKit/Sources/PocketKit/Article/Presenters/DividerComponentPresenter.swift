// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit

class DividerComponentPresenter: ArticleComponentPresenter {
    var componentIndex: Int

    var highlightIndexes: [Int]?

    private let component: DividerComponent

    init(component: DividerComponent, componentIndex: Int) {
        self.component = component
        self.componentIndex = componentIndex
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
