// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
