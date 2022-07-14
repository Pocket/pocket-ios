import UIKit


class ItemPlaceholderCell: UICollectionViewListCell {
    private let label: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 124).with(priority: .defaultHigh),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        label.text = "[PLACEHOLDER]"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
