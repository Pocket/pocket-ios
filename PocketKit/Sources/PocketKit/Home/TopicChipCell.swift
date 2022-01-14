import UIKit
import Sync


protocol TopicChipCellModel {
    var attributedTitle: NSAttributedString? { get }
    var isSelected: Bool { get }
}

class TopicChipCell: UICollectionViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let toggledBackground = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "topic-chip"

        contentView.addSubview(toggledBackground)
        contentView.addSubview(titleLabel)

        let cornerRadius = TopicChipCell.height / 2
        selectedBackgroundView = UIView()
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.backgroundColor = UIColor(.ui.grey1).withAlphaComponent(0.1)

        layer.borderColor = UIColor(.ui.grey5).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius

        toggledBackground.isHidden = true
        toggledBackground.backgroundColor = UIColor(.ui.grey5)
        toggledBackground.layer.cornerRadius = cornerRadius

        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggledBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

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
        toggledBackground.isHidden = !model.isSelected
    }
}

extension TopicChipCell {
    static let height: CGFloat = 40

    static func width(chip: TopicChipPresenter) -> CGFloat {
        let rect = chip.attributedTitle?.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: Self.height),
            options: [.usesLineFragmentOrigin],
            context: nil
        ) ?? .zero

        return rect.width.rounded(.up) + 24
    }
}
