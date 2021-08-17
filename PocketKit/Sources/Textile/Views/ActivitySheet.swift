import SwiftUI
import UIKit


struct ActivitySheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController

    private let activityItems: [Any]

    init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // no op
    }
}
