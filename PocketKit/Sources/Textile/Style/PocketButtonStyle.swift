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
        case destructive
    }

    // TODO: Need to create other button types shown in Figma
    public enum Size {
        case small
        case normal
    }

    let size: Size
    let variation: Variation

    private enum Constants {
        static let cornerRadius: CGFloat = 13
        static let buttonHeight: CGFloat = 52
        static let padding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        static let smallStyle = Style.header.sansSerif.p4.with(weight: .medium)
        static let style = Style.header.sansSerif.h6

        enum Primary {
            static let tintColor = Color(.ui.grey1)
            static let backgroundColor = Color(UIColor(.ui.teal2).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
            static let pressedBackgroundColor = Color(UIColor(.ui.teal1).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
            static let foregroundColor = Color(.ui.white)
            static let pressedForegroundColor = Color(.ui.white)
        }

        enum Secondary {
            static let tintColor = Color(.ui.grey1)
            static let backgroundColor = Color(.clear)
            static let pressedBackgroundColor = Color(.ui.black1)
            static let foregroundColor = Color(.ui.black1)
            static let pressedForegorundColor = Color(.ui.white1)
        }

        enum InternalInfoLink {
            static let tintColor = Color(.ui.grey5)
            static let backgroundColor = Color(.ui.grey6)
            static let pressedBackgroundColor = Color(.ui.black1)
            static let foregroundColor = Color(.ui.grey4)
            static let pressedForegorundColor = Color(.ui.white1)
            static let buttonHeight: CGFloat = 34
            static let style = Style.header.sansSerif.p4
        }

        enum Destructive {
            static let tintColor = Color(.ui.grey1)
            static let backgroundColor = Color(.ui.coral1)
            static let pressedBackgroundColor = Color(.ui.white)
            static let foregroundColor = Color(.ui.white)
            static let pressedForegroundColor = Color(.ui.white)
        }
    }

    public init(_ variation: Variation, _ size: Size = .normal) {
        self.variation = variation
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        PocketButton(configuration: configuration, variation: self.variation, size: self.size)
    }

    struct PocketButton: View {
        let configuration: ButtonStyle.Configuration

        let variation: Variation
        let size: Size

        @Environment(\.isEnabled)
        private var isEnabled: Bool

        var body: some View {
            // TODO: Refactor this to match our components in Figma
            if size == .small && variation == .primary {
                configuration.label
                    .multilineTextAlignment(SwiftUI.TextAlignment(Constants.style.paragraph.alignment))
                    .lineSpacing(Constants.style.paragraph.lineSpacing ?? 0)
                    .opacity(isEnabled ? 1.0 : 0.5)
                    .font(Font(Constants.smallStyle.fontDescriptor))
                    .padding(Constants.padding)
                    .tint(Constants.Primary.tintColor)
                    .background( configuration.isPressed ? Constants.Primary.pressedBackgroundColor : Constants.Primary.backgroundColor)
                    .foregroundColor(configuration.isPressed ? Constants.Primary.pressedForegroundColor : Constants.Primary.foregroundColor)
                    .cornerRadius(Constants.cornerRadius)
            } else {
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
                                .stroke(Color(.ui.black1), lineWidth: 2)
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
                .if(variation == .destructive) { view in
                    view
                        .font(Font(Constants.style.fontDescriptor))
                        .frame(height: Constants.buttonHeight)
                        .tint(Constants.Destructive.tintColor)
                        .background( configuration.isPressed ? Constants.Destructive.pressedBackgroundColor : Constants.Destructive.backgroundColor)
                        .foregroundColor(configuration.isPressed ? Constants.Destructive.pressedForegroundColor : Constants.Destructive.foregroundColor)
                        .cornerRadius(Constants.cornerRadius)
                }
            }
            }
    }
}

struct PocketButton_PreviewProvider: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Primary Action") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.primary))

            Button("Secondary Action") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.secondary))

            Button("Destructive Action") {}
                .padding()
                .buttonStyle(PocketButtonStyle(.destructive))

            Button("Internal Info Link") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.internalInfoLink))
        }
        .previewDisplayName("Enabled - Light")
        .preferredColorScheme(.light)

        VStack {
            Button("Primary Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.primary))

            Button("Secondary Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.secondary))

            Button("Destructive Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.destructive))

            Button("Internal Info Link") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.internalInfoLink))
        }
        .previewDisplayName("Disabled - Light")
        .preferredColorScheme(.light)

        VStack {
            Button("Primary Action") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.primary))

            Button("Secondary Action") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.secondary))

            Button("Destructive Action") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.destructive))

            Button("Internal Info Link") {}
            .padding()
            .buttonStyle(PocketButtonStyle(.internalInfoLink))
        }
        .previewDisplayName("Enabled - Dark")
        .preferredColorScheme(.dark)

        VStack {
            Button("Primary Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.primary))

            Button("Secondary Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.secondary))

            Button("Destructive Action") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.destructive))

            Button("Internal Info Link") {}
            .disabled(true)
            .padding()
            .buttonStyle(PocketButtonStyle(.internalInfoLink))
        }
        .previewDisplayName("Disabled - Dark")
        .preferredColorScheme(.dark)
    }
}
