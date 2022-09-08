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

    private let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.teal6)
        return view
    }()

    private var subscriptions: [AnyCancellable] = []
    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedView.publisher(for: \.bounds).sink { [weak self] value in
            self?.selectedView.layer.cornerRadius = value.height / 2
        }.store(in: &subscriptions)

        // Build View Hierarchy
        contentView.addSubview(selectedView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)

        // Apply Layout
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedView.translatesAutoresizingMaskIntoConstraints = false

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

            selectedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        selectedView.isHidden = !model.isSelected
    }
}
