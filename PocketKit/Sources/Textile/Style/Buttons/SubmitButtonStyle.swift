// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI

public struct SubmitButtonStyle: ButtonStyle {
    private struct Constants {
        static let cornerRadius: CGFloat = 4
        static let reasonRowHeight: CGFloat = 44
        static let reasonRowSelectedColor = Color(.ui.teal6)
        static let reasonRowDeselectedColor: Color = .clear
        static let reasonRowTint = Color(.ui.teal2)
        static let commentRowHeight: CGFloat = 92
        static let submitButtonHeight: CGFloat = 52
        static let submitButtonTintColor = Color(.ui.grey1)
        static let submitButtonBackgroundColor = Color(.ui.teal2)
    }

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let style = Style.header.sansSerif.h6.with(color: .ui.white)

        Button(action: {}) {
            HStack {
                Spacer()
                configuration.label
                Spacer()
            }
        }.frame(height: Constants.submitButtonHeight)
            .tint(Constants.submitButtonTintColor)
            .background(Constants.submitButtonBackgroundColor)
            .cornerRadius(Constants.cornerRadius)
            .font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
            .multilineTextAlignment(SwiftUI.TextAlignment(style.paragraph.alignment))
            .lineSpacing(style.paragraph.lineSpacing ?? 0)
    }
}

struct SubmitButton_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Primary Action")
        }.padding()
            .buttonStyle(SubmitButtonStyle())
            .previewDisplayName("Primary Action")
    }
}
