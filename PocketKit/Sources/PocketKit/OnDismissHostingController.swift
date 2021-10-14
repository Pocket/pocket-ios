import SwiftUI


class OnDismissHostingController<T: View>: UIHostingController<T> {
    private let onDismiss: () -> Void

    init(rootView: T, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed {
            onDismiss()
        }
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
