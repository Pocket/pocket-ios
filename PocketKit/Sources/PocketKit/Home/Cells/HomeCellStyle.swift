// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

/// Standard styling for Home cells:
/// - padding
/// - background color
/// - shape and corner radius
/// - shadow color, size and offset
struct HomeCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.ui.homeCellBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(.ui.border), radius: 6, x: 0, y: 0)
    }
}

extension View {
    func homeCellStyle() -> some View {
        modifier(HomeCellStyle())
    }
}
