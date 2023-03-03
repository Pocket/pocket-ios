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
    }

    let variation: Variation

    private struct Constants {
        static let cornerRadius: CGFloat = 4
        static let buttonHeight: CGFloat = 52
        static let primaryButtonTintColor = Color(.ui.grey1)
        static let primaryButtonBackgroundColor = Color(.ui.teal2)
        static let primaryButtonPressedBackgroundColor = Color(.ui.teal1)

        static let secondaryButtonTintColor = Color(.ui.grey1)
        static let secondaryButtonBackgroundColor = Color(.clear)
        static let secondaryButtonPressedBackgroundColor = Color(.ui.black)

        static let secondaryButtonForegorundColor = Color(.ui.black)
        static let secondaryButtonPressedForegorundColor = Color(.ui.white)
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

        let baseStyle = Style.header.sansSerif.h6
        let primaryStyle = Style.header.sansSerif.h6.with(color: .ui.white)

        @Environment(\.isEnabled)
        private var isEnabled: Bool

        var body: some View {
            HStack {
                Spacer()
                configuration.label
                Spacer()
            }
            .frame(height: Constants.buttonHeight)
            .font(Font(baseStyle.fontDescriptor))
            .multilineTextAlignment(SwiftUI.TextAlignment(baseStyle.paragraph.alignment))
            .lineSpacing(baseStyle.paragraph.lineSpacing ?? 0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .if(variation == .secondary) {  view in
               view.overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.ui.black), lineWidth: 2)
                )
               .background( configuration.isPressed ? Constants.secondaryButtonPressedBackgroundColor : Constants.secondaryButtonBackgroundColor)
               .foregroundColor(configuration.isPressed ? Constants.secondaryButtonPressedForegorundColor : Constants.secondaryButtonForegorundColor)
            }
            .if(variation == .primary) { view in
                view.tint(Constants.primaryButtonTintColor)
                    .background( configuration.isPressed ? Constants.primaryButtonPressedBackgroundColor : Constants.primaryButtonBackgroundColor)
                    .cornerRadius(Constants.cornerRadius)
                    .foregroundColor(Color(primaryStyle.colorAsset))
            }
        }
    }
}

struct PocketButton_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Button("Primary Action") {
        }.padding()
            .buttonStyle(PocketButtonStyle(.primary))
            .previewDisplayName("Primary - Enabled")

        Button("Primary Action") {
        }
        .disabled(true)
        .padding()
        .buttonStyle(PocketButtonStyle(.primary))
            .previewDisplayName("Primary - Disabled")

        Button("Secondary Action") {
        }.padding()
            .buttonStyle(PocketButtonStyle(.secondary))
            .previewDisplayName("Secondary - Enabled")

        Button("Secondary Action") {
        }
        .disabled(true)
        .padding()
        .buttonStyle(PocketButtonStyle(.secondary))
            .previewDisplayName("Secondary - Disabled")
    }
}
