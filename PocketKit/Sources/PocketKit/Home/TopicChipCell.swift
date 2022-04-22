import UIKit
import Sync


protocol TopicChipCellModel {
    var attributedTitle: NSAttributedString? { get }
    var iconImage: UIImage? { get }
    var isSelected: Bool { get }
}

class TopicChipCell: UICollectionViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 7.5
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
        layer.borderColor = UIColor(.clear).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius

        toggledBackground.isHidden = true
        toggledBackground.backgroundColor = UIColor(.ui.teal6)
        toggledBackground.layer.cornerRadius = cornerRadius
        toggledBackground.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = UIColor(.clear)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

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
        iconImageView.image = model.iconImage
        toggledBackground.isHidden = !model.isSelected

        if model.isSelected {
            iconImageView.tintColor = UIColor(.ui.teal1)
        }
    }
}

extension TopicChipCell {
    static func height(chip: TopicChipPresenter) -> CGFloat {
        let size = chip.attributedTitle?.sizeFitting() ?? .zero
        return size.height.rounded(.up) + 20
    }

    static func width(chip: TopicChipPresenter) -> CGFloat {
        let size = chip.attributedTitle?.sizeFitting() ?? .zero
        let imageSize = chip.iconImage?.size.width ?? .zero
        return size.width.rounded(.up) + imageSize + 28
    }
}
