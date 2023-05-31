import SwiftUI

public struct ActionsPrimaryButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(UIColor(.ui.teal1).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))) : Color(UIColor(.ui.teal2).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
            .cornerRadius(13)
    }
}