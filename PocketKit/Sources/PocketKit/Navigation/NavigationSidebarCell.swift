import UIKit
import Combine

class NavigationSidebarCell: UICollectionViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private var subscriptions: [AnyCancellable] = []
    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(.ui.teal6)
        selectedBackgroundView?.publisher(for: \.bounds).sink { [weak self] value in
            self?.selectedBackgroundView?.layer.cornerRadius = value.height / 2
        }.store(in: &subscriptions)

        // Build View Hierarchy
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)

        // Apply Layout
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavigationSidebarCell {
    func configure(model: NavigationSidebarCellViewModel) {
        titleLabel.attributedText = model.attributedTitle
        iconImageView.tintColor = model.iconImageTintColor
        iconImageView.image = model.iconImage
    }
}
