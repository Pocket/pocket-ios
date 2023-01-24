import Foundation
import SwiftUI
import Textile

protocol EmptyStateViewModel {
    var imageAsset: ImageAsset { get }
    var maxWidth: CGFloat { get }
    var icon: ImageAsset? { get }
    var headline: String { get }
    var detailText: String? { get }
    var buttonText: String? { get }
    var webURL: URL? { get }
    var accessibilityIdentifier: String { get }
}
