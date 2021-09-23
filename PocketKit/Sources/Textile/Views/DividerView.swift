import UIKit


public class DividerView: UICollectionReusableView {
    private let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(line)
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.centerYAnchor.constraint(equalTo: centerYAnchor),
            line.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        line.backgroundColor = UIColor(.ui.grey6)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
