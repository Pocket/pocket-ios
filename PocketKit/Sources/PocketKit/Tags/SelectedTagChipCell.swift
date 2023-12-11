// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile

protocol SelectedTagChipModel {
    var name: String { get }
    var attributedTitle: NSAttributedString { get }
    var iconImage: UIImage { get }
    var closeAction: UIAction? { get }
}

class SelectedTagChipCell: UICollectionViewCell {
    enum Constants {
        static let imagePadding: CGFloat = 8
        static let padding = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        static let closeUIImage = UIImage(systemName: "xmark.circle.fill")
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

    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = Constants.closeUIImage?
            .resized(to: CGSize(width: 16, height: 16))
            .withTintColor(UIColor(.ui.grey4))
            .addImagePadding(width: 10, height: 10)
        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "close-button"
        return button
    }()

    private let iconImageView = UIImageView()
    private let toggledBackground = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "selected-tag-chip"

        contentView.addSubview(toggledBackground)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(closeButton)

        let cornerRadius = frame.size.height / 2
        layer.cornerRadius = cornerRadius

        toggledBackground.backgroundColor = UIColor(.ui.teal6)
        toggledBackground.layer.cornerRadius = cornerRadius

        stackView.backgroundColor = UIColor(.clear)

        toggledBackground.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = Constants.padding

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
}

extension SelectedTagChipCell {
    struct Model: SelectedTagChipModel {
        var name: String
        var closeAction: UIAction?
        var iconImage: UIImage {
            UIImage(asset: .tag)
        }

        var attributedTitle: NSAttributedString {
            NSAttributedString(string: name, style: .title)
        }
    }

    func configure(model: SelectedTagChipModel) {
        titleLabel.attributedText = model.attributedTitle
        titleLabel.textAlignment = .center

        if let action = model.closeAction {
            closeButton.addAction(action, for: .primaryActionTriggered)
        }

        iconImageView.image = model.iconImage
        iconImageView.contentMode = .center
        iconImageView.sizeToFit()
        iconImageView.tintColor = UIColor(.ui.teal2)
    }
}

extension SelectedTagChipCell {
    static func height(model: SelectedTagChipModel) -> CGFloat {
        let textHeight = model.attributedTitle.sizeFitting().height.rounded(.up)
        return Constants.padding.top + textHeight + Constants.padding.bottom
    }

    static func width(model: SelectedTagChipModel) -> CGFloat {
        let textWidth = model.attributedTitle.sizeFitting().width.rounded(.up)
        let imageSize = model.iconImage.size.width
        let closeImageSize = Constants.closeUIImage?.size.width ?? .zero
        let imagePadding: CGFloat = imageSize > 0 ? 8 : Constants.imagePadding
        return Constants.padding.left + imageSize + imagePadding + textWidth + imagePadding + closeImageSize + Constants.padding.right
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with(color: .ui.teal2)
}
