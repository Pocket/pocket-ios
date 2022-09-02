import UIKit
import Textile

class NavigationHeaderView: UICollectionReusableView {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(asset: .pocketWordmark)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(logoImageView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Style {
    static let navigationHeaderTitle: Style = .header.sansSerif.p1.with(size: 28)
}
