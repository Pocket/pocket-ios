// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedPocketKit

/// Cell for the primary/hero items in Home and Collections
class HomeItemCell: UICollectionViewCell {
    let topView: HomeItemView

    override init(frame: CGRect) {
        topView = HomeItemView(frame: .zero)
        super.init(frame: frame)
        topView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topView)
        contentView.pinSubviewToAllEdges(topView)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not welcome here")
    }
}

// MARK: configuration
extension HomeItemCell {
    func configure(model: ItemCellViewModel) {
        topView.configure(model: model)
    }
}
