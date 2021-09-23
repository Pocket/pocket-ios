import UIKit
import Textile


private extension Style {
    static let saveTitle: Style = .header.sansSerif.p3.with(color: .ui.grey4).with(weight: .medium)
}

extension UIButton {
    static func recommendationButton(configuration: UIButton.Configuration, primaryAction: UIAction?) -> UIButton {
        let button = UIButton(configuration: configuration, primaryAction: primaryAction)
        var config = configuration

        config.imageColorTransformer = UIConfigurationColorTransformer { _ in
            switch button.state {
            case .selected, .highlighted:
                return UIColor(.ui.grey1)
            default:
                return UIColor(.ui.grey4)
            }
        }

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            switch button.state {
            case .selected, .highlighted:
                return Style.saveTitle.with(color: .ui.grey1).attributes
            default:
                return Style.saveTitle.attributes
            }
        }

        button.configuration = config
        return button
    }
}
