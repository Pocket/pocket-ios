import Foundation

public enum TextAlignment {
    case left
    case right

    public init(language: String?) {
        let direction = Locale.characterDirection(forLanguage: language ?? "en")

        switch direction {
        case .rightToLeft:
            self = .right
        case .unknown, .leftToRight, .topToBottom, .bottomToTop:
            self = .left
        @unknown default:
            self = .left
        }
    }
}
