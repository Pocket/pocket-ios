import UIKit
import Textile

class RecommendationButton: UIButton {
    init(asset: ImageAsset) {
        super.init(frame: .zero)

        configuration = .plain()

        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 4,
            bottom: 16,
            trailing: 4
        )
        configuration?.image = UIImage(asset: asset)
            .resized(to: CGSize(width: 20, height: 20))
            .withTintColor(UIColor(.ui.grey8), renderingMode: .alwaysOriginal)

        configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            self?.imageColor() ?? UIColor(.ui.grey8)
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
            return UIColor(.ui.grey8)
        }
    }
}
