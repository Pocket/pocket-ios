// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// How to check if diabled from: https://stackoverflow.com/questions/59169436/swiftui-buttonstyle-how-to-check-if-button-is-disabled-or-enabled

import Foundation
import SwiftUI

public struct PocketButtonStyle: ButtonStyle {
    public enum Variation {
        case primary
        case secondary
        case internalInfoLink
    }

    let variation: Variation

    private struct Constants {
        static let cornerRadius: CGFloat = 4
        static let buttonHeight: CGFloat = 52
        static let style = Style.header.sansSerif.h6

        struct Primary {
            static let tintColor = Color(.ui.grey1)
            static let backgroundColor = Color(.ui.teal2)
            static let pressedBackgroundColor = Color(.ui.teal1)
            static let foregroundColor = Color(.ui.white)
            static let pressedForegroundColor = Color(.ui.white)
        }

        struct Secondary {
            static let tintColor = Color(.ui.grey1)
            static let backgroundColor = Color(.clear)
            static let pressedBackgroundColor = Color(.ui.black)
            static let foregroundColor = Color(.ui.black)
            static let pressedForegorundColor = Color(.ui.white)
        }

        struct InternalInfoLink {
            static let tintColor = Color(.ui.grey5)
            static let backgroundColor = Color(.ui.grey6)
            static let pressedBackgroundColor = Color(.ui.black)
            static let foregroundColor = Color(.ui.grey4)
            static let pressedForegorundColor = Color(.ui.white)
            static let buttonHeight: CGFloat = 34
            static let style = Style.header.sansSerif.p4
        }
    }

    public init(_ variation: Variation) {
        self.variation = variation
    }

    public func makeBody(configuration: Configuration) -> some View {
        PocketButton(configuration: configuration, variation: self.variation)
    }

    struct PocketButton: View {
        let configuration: ButtonStyle.Configuration

        let variation: Variation

        @Environment(\.isEnabled)
        private var isEnabled: Bool

        var body: some View {
            HStack {
                Spacer()
                configuration.label
                if variation == .internalInfoLink {
                    SFIcon(SFIconModel("chevron.right", size: CGFloat(Constants.InternalInfoLink.style.fontDescriptor.size)-2, color: configuration.isPressed ? Constants.InternalInfoLink.pressedForegorundColor : Constants.InternalInfoLink.foregroundColor))
                }
                Spacer()
            }
            .multilineTextAlignment(SwiftUI.TextAlignment(Constants.style.paragraph.alignment))
            .lineSpacing(Constants.style.paragraph.lineSpacing ?? 0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .if(variation == .secondary) {  view in
               view
                    .font(Font(Constants.style.fontDescriptor))
                    .frame(height: Constants.buttonHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(.ui.black), lineWidth: 2)
                    )
                   .background( configuration.isPressed ? Constants.Secondary.pressedBackgroundColor : Constants.Secondary.backgroundColor)
                   .foregroundColor(configuration.isPressed ? Constants.Secondary.pressedForegorundColor: Constants.Secondary.foregroundColor)
            }
            .if(variation == .primary) { view in
                view
                    .font(Font(Constants.style.fontDescriptor))
                    .frame(height: Constants.buttonHeight)
                    .tint(Constants.Primary.tintColor)
                    .background( configuration.isPressed ? Constants.Primary.pressedBackgroundColor : Constants.Primary.backgroundColor)
                    .foregroundColor(configuration.isPressed ? Constants.Primary.pressedForegroundColor : Constants.Primary.foregroundColor)
                    .cornerRadius(Constants.cornerRadius)
            }
            .if(variation == .internalInfoLink) { view in
                view
                    .font(Font(Constants.InternalInfoLink.style.fontDescriptor))
                    .frame(height: Constants.InternalInfoLink.buttonHeight)
                    .tint(Constants.InternalInfoLink.tintColor)
                    .background( configuration.isPressed ? Constants.InternalInfoLink.pressedBackgroundColor : Constants.InternalInfoLink.backgroundColor)
                    .foregroundColor(configuration.isPressed ? Constants.InternalInfoLink.pressedForegorundColor : Constants.InternalInfoLink.foregroundColor)
                    .cornerRadius(Constants.cornerRadius)
            }
        }
    }
}

struct PocketButton_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Button("Primary Action") {}
        .padding()
        .buttonStyle(PocketButtonStyle(.primary))
        .previewDisplayName("Primary - Enabled")

        Button("Primary Action") {}
        .disabled(true)
        .padding()
        .buttonStyle(PocketButtonStyle(.primary))
        .previewDisplayName("Primary - Disabled")

        Button("Secondary Action") {}
        .padding()
        .buttonStyle(PocketButtonStyle(.secondary))
        .previewDisplayName("Secondary - Enabled")

        Button("Secondary Action") {}
        .disabled(true)
        .padding()
        .buttonStyle(PocketButtonStyle(.secondary))
        .previewDisplayName("Secondary - Disabled")

        Button("Internal Info Link") {}
        .padding()
        .buttonStyle(PocketButtonStyle(.internalInfoLink))
        .previewDisplayName("Internal Info Link - Enabled")

        Button("Internal Info Link") {}
        .disabled(true)
        .padding()
        .buttonStyle(PocketButtonStyle(.internalInfoLink))
        .previewDisplayName("Internal Info Link - Disabled")
    }
}
