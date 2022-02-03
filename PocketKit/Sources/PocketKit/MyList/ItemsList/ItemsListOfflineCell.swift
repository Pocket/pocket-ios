import UIKit
import Textile


class ItemsListOfflineCell: UICollectionViewCell {
    enum Constants {
        static let image = UIImage(asset: .looking)
        static let text = NSAttributedString(string: "No Internet Connection", style: .header.sansSerif.h2)
        static let detailText = NSAttributedString(
            string: "Looks like you're offline. Try checking your mobile data or wifi.",
            style: .header.sansSerif.p2.with { $0.with(alignment: .center).with(lineHeight: .explicit(28)) }
        )
        
        static let imageSpacing: CGFloat = 48
        static let stackSpacing: CGFloat = 16
        static let padding: CGFloat = 18
        
        static let buttonColor = UIColor(.ui.white1)
        static let buttonHighlightedColor = UIColor(.ui.grey1).withAlphaComponent(0.5)
        static let buttonContentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let buttonTitle = NSAttributedString(string: "Try Again", style: .header.sansSerif.p2)
    }
    
    private let imageView: UIImageView = {
        return UIImageView(image: Constants.image)
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.attributedText = Constants.text
        return label
    }()
    
    private let detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.attributedText = Constants.detailText
        return label
    }()
    
    private var actionButton: UIButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.attributedTitle = AttributedString(Constants.buttonTitle)
        config.cornerStyle = .capsule
        config.background.strokeColor = UIColor(.ui.grey5)
        config.contentInsets = Constants.buttonContentInsets
        
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.baseBackgroundColor = button.isHighlighted ? Constants.buttonHighlightedColor : Constants.buttonColor
            button.configuration = config
        }
        return button
    }()
    
    var buttonAction: (() -> ())? = nil
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textLabel, detailTextLabel, actionButton])
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
        
        let action = UIAction(title: "") { [weak self] _ in self?.buttonAction?() }
        actionButton.addAction(action, for: .primaryActionTriggered)
        
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
        + Constants.buttonContentInsets.top
        + Constants.buttonTitle.sizeFitting(availableWidth: availableWidth).height
        + Constants.buttonContentInsets.bottom
    }
}
