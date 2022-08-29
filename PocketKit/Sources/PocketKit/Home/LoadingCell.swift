import UIKit
import Textile

class LoadingCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingCell {
    private func setupContentView() {
        contentView.backgroundColor = .clear

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(.ui.grey1)
        contentView.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }
}
