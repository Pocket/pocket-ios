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
    case reportIssue(String)
}
