import SwiftUI
import Textile

struct SettingsRowToggle: View {
    private var title: String

    @ObservedObject private var model: AccountViewModel

    let action: () -> Void

    init(title: String, model: AccountViewModel, action: @escaping () -> Void) {
        self.title = title
        self.model = model
        self.action = action
    }

    var body: some View {
        VStack {
            Toggle(title, isOn: model.$appBadgeToggle)
                .onChange(of: model.appBadgeToggle) { newValue in
                    self.action()
                }
        }
    }
}
