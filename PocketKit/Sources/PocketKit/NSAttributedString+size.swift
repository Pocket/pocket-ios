import Foundation
import CoreGraphics

extension NSAttributedString {
    func sizeFitting(
        availableWidth: CGFloat = .greatestFiniteMagnitude,
        availableHeight: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        guard !string.isEmpty else {
            return .zero
        }

        let rect = boundingRect(
            with: CGSize(width: availableWidth, height: availableHeight),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        )

        return CGSize(width: min(rect.width.rounded(.up), availableWidth), height: min(rect.height.rounded(.up), availableHeight))
    }
}
