import UIKit
import Textile

class UnsupportedComponentCell: UICollectionViewCell {
    private lazy var unsupportedView: ArticleComponentUnavailableView = {
        let view = ArticleComponentUnavailableView()
        view.text = "This element is currently unsupported.".localized()
        return view
    }()

    var action: (() -> Void)? {
        get {
            return unsupportedView.action
        }
        set {
            unsupportedView.action = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(unsupportedView)

        unsupportedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unsupportedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            unsupportedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unsupportedView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            unsupportedView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
