// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class DividerComponentCell: UICollectionViewCell {
    enum Constants {
        static let dividerHeight: CGFloat = 3
    }

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey6)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(dividerView)

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dividerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dividerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
