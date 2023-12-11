// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Textile
import Localization

class UnsupportedComponentCell: UICollectionViewCell {
    private lazy var unsupportedView: ArticleComponentUnavailableView = {
        let view = ArticleComponentUnavailableView()
        view.text = Localization.thisElementIsCurrentlyUnsupported
        return view
    }()

    var action: (() -> Void)? {
        get {
            return unsupportedView.action
        }
        set {
            unsupportedView.action = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(unsupportedView)

        unsupportedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unsupportedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            unsupportedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unsupportedView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            unsupportedView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
