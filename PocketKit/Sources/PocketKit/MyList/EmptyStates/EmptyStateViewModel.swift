// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import Textile

protocol EmptyStateViewModel {
    var imageAsset: ImageAsset { get }
    var maxWidth: CGFloat { get }
    var icon: ImageAsset? { get }
    var headline: String? { get }
    var detailText: String? { get }
    var buttonType: ButtonType? { get }
    var webURL: URL? { get }
    var accessibilityIdentifier: String { get }
}

enum ButtonType {
    case normal(String)
    case premium(String)
    case reportIssue(text: String, email: String)
}
