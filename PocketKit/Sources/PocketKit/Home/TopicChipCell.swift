import UIKit
import Sync


class TopicChipCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.layer.cornerRadius = TopicChipCell.height / 2
        selectedBackgroundView?.backgroundColor = UIColor(.ui.grey1).withAlphaComponent(0.1)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])

        layer.borderColor = UIColor(.ui.grey5).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = TopicChipCell.height / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TopicChipCell {
    static let height: CGFloat = 40

    static func width(chip: TopicChipPresenter) -> CGFloat {
        let rect = chip.attributedTitle.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: Self.height),
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        return rect.width.rounded(.up) + 24
    }
}
