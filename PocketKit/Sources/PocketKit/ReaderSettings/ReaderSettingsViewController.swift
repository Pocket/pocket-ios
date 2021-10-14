import SwiftUI


class ReaderSettingsViewController: OnDismissHostingController<ReaderSettingsView> {
    init(settings: ReaderSettings, onDismiss: @escaping () -> Void) {
        super.init(
            rootView: ReaderSettingsView(settings: settings),
            onDismiss: onDismiss
        )
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
