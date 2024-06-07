// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile

class SectionHeaderView: UICollectionReusableView {
    static let kind = "SectionHeader"
    static let buttonImageSize = CGSize(width: 6.75, height: 12)
    static let stackSpacing: CGFloat = 10

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let seeAllButton: UIButton = {
        var configuration = UIButton.Configuration.plain()

        configuration.imagePadding = 10
        configuration.imagePlacement = .trailing
        configuration.contentInsets.leading = 0
        configuration.contentInsets.trailing = 0

        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.accessibilityIdentifier = "see-all-button"
        button.isHidden = true
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = stackSpacing
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        headerStack.addArrangedSubview(headerLabel)
        headerStack.addArrangedSubview(seeAllButton)

        addSubview(headerStack)

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Cannot instantiate \(Self.self) from storyboard/xib")
    }
}

extension SectionHeaderView {
    struct Model {
        let name: String
        let buttonTitle: String
        let buttonImage: UIImage?
        var buttonAction: (() -> Void)?

        var attributedHeaderText: NSAttributedString {
            NSAttributedString(string: name, style: .sectionHeader)
        }

        @MainActor
        func height(width: CGFloat) -> CGFloat {
            let buttonWidth = NSAttributedString(string: buttonTitle, style: .buttonText).sizeFitting().width + buttonImageSize.width
            return attributedHeaderText.sizeFitting(availableWidth: width - stackSpacing - buttonWidth).height + 16
        }
    }

    func configure(model: Model) {
        headerLabel.attributedText = model.attributedHeaderText

        var config = seeAllButton.configuration
        config?.attributedTitle = AttributedString(
            model.buttonTitle,
            attributes: Style.buttonText.attributes
        )
        config?.image = model.buttonImage?
            .resized(to: Self.buttonImageSize)
            .withTintColor(UIColor(.ui.teal2), renderingMode: .alwaysOriginal)
        seeAllButton.configuration = config

        let buttonAction = UIAction(title: "", identifier: .seeAllPrimary) { _ in
            model.buttonAction?()
        }
        seeAllButton.addAction(buttonAction, for: .primaryActionTriggered)
        seeAllButton.isHidden = false
    }
}

private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h6.with(weight: .semibold)
    static let buttonText: Style = .header.sansSerif.p4.with(color: .ui.teal2).with(maxScaleSize: 22)
}
