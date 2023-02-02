import UIKit
import Textile

class ItemsListOfflineCell: UICollectionViewCell {
    enum Constants {
        static let image = UIImage(asset: .looking)
        static let text = NSAttributedString(string: "No Internet Connection".localized(), style: .header.sansSerif.h2)
        static let detailText = NSAttributedString(
            string: "Looks like you're offline. Try checking your mobile data or wifi.".localized(),
            style: .header.sansSerif.p2.with { $0.with(alignment: .center).with(lineHeight: .explicit(28)) }
        )

        static let imageSpacing: CGFloat = 48
        static let stackSpacing: CGFloat = 16
        static let padding: CGFloat = 18
    }

    private let imageView: UIImageView = {
        return UIImageView(image: Constants.image)
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = Constants.text
        return label
    }()

    private let detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = Constants.detailText
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textLabel, detailTextLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textStackView])
        stackView.axis = .vertical
        stackView.spacing = Constants.imageSpacing
        stackView.alignment = .center
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    static func height(fitting availableWidth: CGFloat) -> CGFloat {
        return Constants.image.size.height
        + Constants.imageSpacing
        + Constants.text.sizeFitting(availableWidth: availableWidth).height
        + Constants.stackSpacing
        + Constants.detailText.sizeFitting(availableWidth: availableWidth).height
        + Constants.stackSpacing
    }
}
