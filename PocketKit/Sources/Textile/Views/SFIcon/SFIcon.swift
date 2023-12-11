// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public struct SFIcon: View {
    var model: SFIconModel

    public init(_ model: SFIconModel) {
        self.model = model
    }

    public var body: some View {
        if let color = model.secondaryColor {
            Image(systemName: model.systemImage)
                .resizable()
                .scaledToFit()
                .font(.system(size: model.size, weight: model.weight, design: .monospaced))
                .rotationEffect(.degrees(model.rotation))
                .frame(width: model.size, height: model.size)
                .imageScale(.small)
                .symbolRenderingMode(.palette)
                .foregroundStyle(model.color, color)
        } else {
            Image(systemName: model.systemImage)
                .resizable()
                .scaledToFit()
                .font(.system(size: model.size, weight: model.weight, design: .monospaced))
                .rotationEffect(.degrees(model.rotation))
                .frame(width: model.size, height: model.size)
                .imageScale(.small)
                .symbolRenderingMode(.palette)
                .foregroundStyle(model.color)
        }
    }
}
