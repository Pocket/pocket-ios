import UIKit


class SlateHeaderView: UICollectionReusableView {
    static let kind = "SlateHeader"

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(headerLabel)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }

    var attributedHeaderText: NSAttributedString? {
        get {
            headerLabel.attributedText
        }
        set {
            headerLabel.attributedText = newValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Cannot instantiate \(Self.self) from storyboard/xib")
    }
}

extension SlateHeaderView {
    static func height(width: CGFloat, slate: SlateHeaderPresenter) -> CGFloat {
        let adjustedWidth = width - 16

        let rect = slate.attributedHeaderText.boundingRect(
            with: CGSize(width: adjustedWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        return rect.height.rounded(.up) + 16
    }
}
