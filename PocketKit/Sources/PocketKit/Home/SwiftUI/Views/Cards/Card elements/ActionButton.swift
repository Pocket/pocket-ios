// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

/// Two-state action button with an image and an optional title
/// Typical usage: save/saved, favorite/unfavorite
struct ActionButton: View {
    var isActive: Bool

    let activeImage: ImageAsset
    let inactiveImage: ImageAsset
    let activeTitle: String?
    let inactiveTitle: String?
    let highlightedColor: ColorAsset
    let activeColor: ColorAsset
    let inactiveColor: ColorAsset?

    let action: () -> Void

    init(
        isActive: Bool,
        activeImage: ImageAsset,
        inactiveImage: ImageAsset,
        activeTitle: String? = nil,
        inactiveTitle: String? = nil,
        highlightedColor: ColorAsset,
        activeColor: ColorAsset,
        inactiveColor: ColorAsset? = nil,
        action: @escaping () -> Void
    ) {
        self.isActive = isActive
        self.activeImage = activeImage
        self.inactiveImage = inactiveImage
        self.activeTitle = activeTitle
        self.inactiveTitle = inactiveTitle
        self.highlightedColor = highlightedColor
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            EmptyView()
        }
        .buttonStyle(
            ActionButtonStyle(
            isActive: isActive,
            activeImage: activeImage,
            inactiveImage: inactiveImage,
            activeTitle: activeTitle,
            inactiveTitle: inactiveTitle,
            highlightedColor: highlightedColor,
            activeColor: activeColor,
            inactiveColor: inactiveColor
            )
        )
    }
}

private struct ActionButtonStyle: ButtonStyle {
    var isActive: Bool

    let activeImage: ImageAsset
    let inactiveImage: ImageAsset
    let activeTitle: String?
    let inactiveTitle: String?
    let highlightedColor: ColorAsset
    let activeColor: ColorAsset
    let inactiveColor: ColorAsset?

    var defaultColor: ColorAsset {
        guard let inactiveColor else { return activeColor }
        return isActive ? activeColor : inactiveColor
    }

    var image: ImageAsset {
        isActive ? activeImage : inactiveImage
    }

    var title: String? {
        isActive ? activeTitle : inactiveTitle
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Image(asset: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(configuration.isPressed ? highlightedColor : defaultColor))
                .frame(width: 20, height: 20)
            if let title {
                Text(title)
                    .style(configuration.isPressed ? .homeButton.saveTitleHighlighted : .homeButton.saveTitle)
            }
        }
    }
}
