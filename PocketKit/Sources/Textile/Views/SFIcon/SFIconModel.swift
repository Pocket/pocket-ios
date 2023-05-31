// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI

public class SFIconModel: ObservableObject {
    var systemImage: String
    var size: CGFloat
    var weight: Font.Weight
    var rotation: CGFloat
    var color: Color
    var secondaryColor: Color?

    public init(_ systemImage: String, size: CGFloat = 18, weight: Font.Weight = .regular, rotation: CGFloat = 0, color: Color = Color(.ui.black1), secondaryColor: Color? = nil) {
        self.systemImage = systemImage
        self.size = size
        self.weight = weight
        self.rotation = rotation
        self.color = color
        self.secondaryColor = secondaryColor
    }
}
