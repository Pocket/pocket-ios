// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class SortMenuViewCell: UITableViewCell {
    var model: Model? {
        didSet {
            updateModel()
            layoutIfNeeded()
        }
    }

    static let identifier = "SortMenuViewCell"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSelectdBackgroundView()
        setupViewElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configSelectdBackgroundView() {
        let selectedBGViewToSet = UIView()
        selectedBGViewToSet.backgroundColor = UIColor(.ui.teal6)
        selectedBackgroundView = selectedBGViewToSet
    }

    func setupViewElements() {
        contentView.addSubview(titleLabel)
        contentView.layoutMargins = UIEdgeInsets(top: 10.0, left: 68.0, bottom: 10.0, right: 10.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])
    }
}

extension SortMenuViewCell {
    struct Model {
        let isSelected: Bool

        var attributedTitle: NSAttributedString {
            NSAttributedString(string: sortOption.rawValue, style: .header.sansSerif.h8)
        }

        private let sortOption: SortOption

        init(sortOption: SortOption, isSelected: Bool) {
            self.sortOption = sortOption
            self.isSelected = isSelected
        }
    }

    func updateModel() {
        titleLabel.attributedText = model?.attributedTitle
        if model?.isSelected == true {
            backgroundColor = UIColor(.ui.teal6)
        }
    }
}
