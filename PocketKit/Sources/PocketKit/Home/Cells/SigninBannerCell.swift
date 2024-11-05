// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

/// Cell that displays the Sign in or sign up banner at the top of the Home screen in anonymous mode.
/// This cell embeds a SwiftUI view.
class SigninBannerCell: UICollectionViewCell {
    func configure(action: @escaping () -> Void) {
        let view = UIView.embedSwiftUIView(SigninBannerView(action: action))
        contentView.addSubview(view)
        contentView.pinSubviewToAllEdges(view)
        accessibilityIdentifier = "home-signinBanner"
    }
}
