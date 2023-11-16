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
        let size = CGFloat(descriptor.size)

        self = .custom(descriptor.familyName, size: size)
            .weight(Weight(descriptor.weight))
    }
}

public extension Color {
    init(_ asset: ColorAsset) {
        self.init(asset._name, bundle: .module)
    }
}

public extension SwiftUI.TextAlignment {
    init(_ textAlignment: TextAlignment) {
        switch textAlignment {
        case .left:
            self = .leading
        case .right:
            self = .trailing
        case .center, .justified:
            self = .center
        }
    }
}

public extension SwiftUI.Image {
    init(asset: ImageAsset) {
        self.init(uiImage: UIImage(asset: asset))
    }
}

public extension Text {
    func style(_ style: Style) -> some View {
        font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
            .multilineTextAlignment(SwiftUI.TextAlignment(style.paragraph.alignment))
            .lineSpacing(style.paragraph.lineSpacing ?? 0)
            .italic(style.fontDescriptor.slant == .italic)
    }
}

public extension TextField {
    func style(_ style: Style) -> some View {
        font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
    }
}

public extension SecureField {
    func style(_ style: Style) -> some View {
        font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
    }
}

public extension TextEditor {
    func style(_ style: Style) -> some View {
        font(Font(style.fontDescriptor))
            .foregroundColor(Color(style.colorAsset))
    }
}
