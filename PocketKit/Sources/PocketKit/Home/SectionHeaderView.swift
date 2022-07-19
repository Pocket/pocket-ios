import UIKit
import Textile

class SectionHeaderView: UICollectionReusableView {
    static let kind = "SectionHeader"
    static let buttonImageSize = CGSize(width: 6.75, height: 12)
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(.ui.lapis1)
        return label
    }()
    
    private let myListButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(asset: .chevronRight)
            .withTintColor(UIColor(.ui.lapis1), renderingMode: .alwaysTemplate)
            .resized(to: buttonImageSize)
        configuration.imagePadding = 10
        configuration.imagePlacement = .trailing
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.accessibilityIdentifier = "see-all-button"
        button.isHidden = true
        return button
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .equalCentering
        stack.axis = .horizontal

        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        headerStack.addArrangedSubview(headerLabel)
        headerStack.addArrangedSubview(myListButton)
        
        addSubview(headerStack)

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        myListButton.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            headerStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Cannot instantiate \(Self.self) from storyboard/xib")
    }
}

extension SectionHeaderView {
    struct Model {
        var attributedHeaderText: NSAttributedString?
        var buttonHeaderText: String?
        var buttonAction: (() -> ())? = nil
    }
    
    func configure(model: Model) {
        headerLabel.attributedText = model.attributedHeaderText
        updateButtonConfiguration(with: model.buttonHeaderText, and: model.buttonAction)
    }
    
    private func updateButtonConfiguration(with text: String?, and action: (() -> ())?) {
        guard let text = text, let action = action else { return }
        
        myListButton.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.attributedTitle = AttributedString(text, attributes: Style.buttonText.attributes)
            button.configuration = config
        }
        let buttonAction = UIAction(title: "", identifier: .seeAllPrimary) { _ in action() }
        myListButton.addAction(buttonAction, for: .primaryActionTriggered)
        myListButton.isHidden = false
    }
}

extension SectionHeaderView {
    static func height(width: CGFloat, slate: SectionHeaderPresenter) -> CGFloat {
        let adjustedWidth = width - 16

        let rect = slate.attributedHeaderText.boundingRect(
            with: CGSize(width: adjustedWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        return rect.height.rounded(.up) + 16
    }
}

private extension Style {
    static let buttonText: Style = .header.sansSerif.p4.with(color: .ui.lapis1)
}
