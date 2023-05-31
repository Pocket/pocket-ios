// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync

protocol TopicChipCellModel {
    var attributedTitle: NSAttributedString? { get }
    var iconImage: UIImage? { get }
    var isSelected: Bool { get }
}

class TopicChipCell: UICollectionViewCell {
    enum Constants {
        static let imagePadding: CGFloat = 8
        static let padding: CGFloat = 12
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.imagePadding
        return stackView
    }()

    private let iconImageView = UIImageView()

    private let toggledBackground = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "topic-chip"

        contentView.addSubview(toggledBackground)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        let cornerRadius = frame.size.height / 2
        layer.cornerRadius = cornerRadius

        toggledBackground.isHidden = true
        toggledBackground.backgroundColor = UIColor(.ui.teal6)
        toggledBackground.layer.cornerRadius = cornerRadius
        toggledBackground.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = UIColor(.clear)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding
        )

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            toggledBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            toggledBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            toggledBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            toggledBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: TopicChipCellModel) {
        titleLabel.attributedText = model.attributedTitle
        titleLabel.textAlignment = .center

        iconImageView.isHidden = model.iconImage == nil
        iconImageView.image = model.iconImage
        iconImageView.contentMode = .center

        toggledBackground.isHidden = !model.isSelected

        iconImageView.tintColor = model.isSelected ? UIColor(.ui.teal2) : UIColor(.ui.grey1)
    }
}

extension TopicChipCell {
    static func height(chip: TopicChipPresenter) -> CGFloat {
        let textHeight = chip.attributedTitle?.sizeFitting().height.rounded(.up) ?? .zero
        return Constants.padding + textHeight + Constants.padding
    }

    static func width(chip: TopicChipPresenter) -> CGFloat {
        let textWidth = chip.attributedTitle?.sizeFitting().width.rounded(.up) ?? .zero
        let imageSize = chip.iconImage?.size.width ?? 0
        let imagePadding: CGFloat = imageSize > 0 ? 8 : Constants.imagePadding

        return Constants.padding + imageSize + imagePadding + textWidth + Constants.padding
    }
}
