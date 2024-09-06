// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

enum SaveButtonState {
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
}

/// Save/Saved button used in all home cards
struct HomeSaveButton: View {
    @Binding var state: SaveButtonState

    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            EmptyView()
        }
        .buttonStyle(SaveButtonStyle(state: $state))
    }
}

struct SaveButtonStyle: ButtonStyle {
    @Binding var state: SaveButtonState

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            Image(asset: state.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(configuration.isPressed ? .ui.coral1 : .ui.coral2))
                .frame(width: 24, height: 24)

            Text(state.title)
                .style(configuration.isPressed ? .saveTitleHighlighted : .saveTitle)
        }
        .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }
}

private extension Style {
    static let saveTitle: Style = .header.sansSerif.p4.with(weight: .medium).with(maxScaleSize: 17).with(color: .ui.saveButtonText)
    static let saveTitleHighlighted: Style = .header.sansSerif.p4.with(color: .ui.grey1).with(weight: .medium).with(maxScaleSize: 17)
}
