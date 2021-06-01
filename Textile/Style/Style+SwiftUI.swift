// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

extension CGFloat {
    init(_ size: FontDescriptor.Size) {
        self.init(size.size)
    }
}

public extension Font.Weight {
    init(_ weight: FontDescriptor.Weight) {
        switch weight {
        case .regular:
            self = .regular
        case .medium:
            self = .medium
        case .semibold:
            self = .semibold
        case .bold:
            self = .bold
        }
    }
}

public extension Font {
    init(_ descriptor: FontDescriptor) {
        let size = descriptor.size.flatMap(CGFloat.init) ?? 0

        self = descriptor
            .family
            .flatMap { .custom($0.name, size: size) } ?? .system(size: size)

        self = descriptor
            .weight
            .flatMap(Weight.init)
            .flatMap(self.weight) ?? self
    }
}

public extension Color {
    init(_ asset: ColorAsset) {
        self.init(asset._name, bundle: Textiles.bundle)
    }
}

public extension Text {
    func style(_ style: Style) -> Text {
        font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
    }
}
