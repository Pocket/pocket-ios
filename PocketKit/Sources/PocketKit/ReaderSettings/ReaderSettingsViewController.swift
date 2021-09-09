import SwiftUI


class ReaderSettingsViewController: UIHostingController<ReaderSettingsView> {
    private let onDismiss: () -> Void

    init(settings: ReaderSettings, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: ReaderSettingsView(settings: settings))
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
