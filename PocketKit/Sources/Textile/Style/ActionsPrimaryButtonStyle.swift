// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public struct ActionsPrimaryButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(UIColor(.ui.teal1).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))) : Color(UIColor(.ui.teal2).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
            .cornerRadius(13)
    }
}
