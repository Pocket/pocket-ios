// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

private let constants = ListItem.Constants.tags

extension Image {
    func tagIconStyle() -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: constants.icon.size, height: constants.icon.size)
            .foregroundColor(constants.icon.color)
            .padding(.trailing, constants.icon.padding)
    }
}

struct TagBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(constants.padding)
            .background(Rectangle().fill(constants.backgroundColor))
            .cornerRadius(constants.cornerRadius)
    }
}

extension View {
    func tagBodyStyle() -> some View {
        self.modifier(TagBodyStyle())
    }
}
