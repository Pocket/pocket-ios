// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import Textile
import UIKit

class LoadingCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not welcome here 😆")
    }
}

extension LoadingCell {
    private func setupContentView() {
        contentView.backgroundColor = .clear
        let view = UIView.embedSwiftUIView(PocketLoadingView.loadingIndicator(Localization.LoadingView.message))
        contentView.addSubview(view)
        contentView.pinSubviewToAllEdges(view)
    }
}
