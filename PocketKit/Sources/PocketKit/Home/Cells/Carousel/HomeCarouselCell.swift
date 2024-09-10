// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedPocketKit
import SharedWithYou

/// Cell for the carousel items in the Home screen
class HomeCarouselCell: UICollectionViewCell {
    let topView: HomeCarouselViewUIKit

    override init(frame: CGRect) {
        topView = HomeCarouselViewUIKit(frame: .zero)
        super.init(frame: frame)
        accessibilityIdentifier = "home-carousel-item"
        topView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topView)
        contentView.pinSubviewToAllEdges(topView)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not welcome here")
    }

    func configure(with configuration: HomeCarouselCellConfiguration) {
        topView.configure(with: configuration)
    }
}
