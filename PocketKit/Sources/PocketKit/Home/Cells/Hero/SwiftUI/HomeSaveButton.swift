// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

/// Save/Saved button used in all home cards
struct HomeSaveButton: View {
    enum Mode {
        case save
        case saved

        var title: String {
            switch self {
            case .save:
                return Localization.Recommendation.save
            case .saved:
                return Localization.Recommendation.saved
            }
        }

        var image: ImageAsset {
            switch self {
            case .save:
                return .save
            case .saved:
                return .saved
            }
        }

        var textColor: Color {
            switch self {
            case .save:
                return Color(.ui.coral2)
            case .saved:
                return Color(.ui.coral2)
            }
        }
    }
    // TODO: this needs to be changed from outer scope
    @State private var mode: Mode = .save
    @State private var isTitleHidden: Bool = false

    private var titleStyle: Font {
        return Font.custom("SansSerif", size: 17).weight(.medium)
    }

    var body: some View {
        Button(action: {
            // Toggle mode for demonstration purposes
            mode = mode == .save ? .saved : .save
        }) {
            HStack(spacing: 6) {
                Image(asset: mode.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(imageColor())
                    .frame(width: 24, height: 24)

                if !isTitleHidden {
                    Text(mode.title)
                        .font(titleStyle)
                        .foregroundColor(textColor())
                }
            }
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        }
    }

    private func imageColor() -> Color {
        switch mode {
        case .save:
            return Color(.ui.coral2)
        case .saved:
            return Color(.ui.coral2)
        }
    }

    private func textColor() -> Color {
        switch mode {
        case .save:
            return Color(.ui.coral2)
        case .saved:
            return Color(.ui.coral2)
        }
    }
}
