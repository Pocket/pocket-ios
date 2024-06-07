// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@MainActor
protocol ArticleComponentPresenter {
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, onHighlight: ((Int, NSRange, String, String) -> Void)?) -> UICollectionViewCell
    func size(for availableWidth: CGFloat) -> CGSize
    func clearCache()
    func loadContent()
    var highlightIndexes: [Int]? { get }
    var componentIndex: Int { get }
}
