import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let activity: PocketActivity

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activity: activity)
        controller.sheetPresentationController?.detents = [.medium()]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
