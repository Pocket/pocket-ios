import UIKit
import Textile


class RecommendationOverflowButton: UIButton {
    init() {
        super.init(frame: .zero)

        configuration = .plain()
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )
        configuration?.image = UIImage(asset: .alert)
            .withRenderingMode(.alwaysTemplate)

        configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            self?.imageColor() ?? UIColor(.ui.grey4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func imageColor() -> UIColor {
        switch state {
        case .selected, .highlighted:
            return UIColor(.ui.grey1)
        default:
            return UIColor(.ui.grey4)
        }
    }
}
