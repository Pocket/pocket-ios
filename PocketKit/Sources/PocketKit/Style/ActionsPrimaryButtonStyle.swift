import SwiftUI

struct ActionsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.ui.teal1) : Color(.ui.teal2))
            .cornerRadius(4)
    }
}
