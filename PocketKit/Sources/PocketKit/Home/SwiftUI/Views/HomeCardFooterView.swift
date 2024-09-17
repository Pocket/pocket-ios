// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct HomeCardFooterView: View {
    let model: HomeCardModel
    let domain: String?
    let timeToRead: Int32?
    let isSaved: Bool
    let isFavorite: Bool
    let isSyndicated: Bool

    var body: some View {
        makeFooter()
    }
}

// MARK: view builders
private extension HomeCardFooterView {
    /// Footer
    func makeFooter() -> some View {
        HStack(alignment: .bottom) {
            makeFooterDescription()
            Spacer()
            HStack(alignment: .center) {
                makeActionButton()
                makeOverflowMenu()
            }
        }
    }

    /// Footer description
    func makeFooterDescription() -> some View {
        VStack(alignment: .leading, spacing: Self.stackSpacing) {
            if let domain {
                makeDomain(domain)
                    .style(model.domainStyle)
                    .lineLimit(Self.footerElementLineLimit)
                    .accessibilityIdentifier("domain-label")
            }
            if let timeToRead, timeToRead > 0 {
                Text(model.timeToRead(timeToRead))
                    .lineLimit(Self.footerElementLineLimit)
                    .accessibilityIdentifier("time-to-read-label")
            }
        }
    }

    func makeDomain(_ domain: String) -> Text {
        if isSyndicated {
            return Text(domain) + Text(" ") + Text(Image(systemName: "checkmark.seal"))
        } else {
            return Text(domain)
        }
    }

    /// Action button: save/saved and/or favorite
    @ViewBuilder
    func makeActionButton() -> some View {
        HStack(alignment: .bottom) {
            if let favoriteAction = model.favoriteAction {
                makeFavoriteButton(handler: favoriteAction.action)
            }
            makeSaveButton()
        }
    }

    func makeFavoriteButton(handler: @escaping (() -> Void)) -> some View {
        HomeActionButton(
            isActive: isFavorite == false,
            activeImage: .favoriteFilled,
            inactiveImage: .favorite,
            highlightedColor: .branding.amber1,
            activeColor: .branding.amber4,
            inactiveColor: .ui.grey8
        ) {
            handler()
        }
        .accessibilityIdentifier("save-button")
    }

    func makeSaveButton() -> some View {
        HomeActionButton(
            isActive: isSaved,
            activeImage: .saved,
            inactiveImage: .save,
            activeTitle: Localization.Recommendation.saved,
            inactiveTitle: Localization.Recommendation.save,
            highlightedColor: .ui.coral1,
            activeColor: .ui.coral2
        ) {
            model.saveAction(isSaved: isSaved)
        }
        .accessibilityIdentifier("save-button")
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            ForEach(model.overflowActions, id: \.self) { buttonAction in
                if let title = buttonAction.title {
                    Button(action: {
                        buttonAction.action()
                    }) {
                        Text(title)
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(Color(.ui.saveButtonText))
        }
        .accessibilityIdentifier("overflow-button")
    }
}

// MARK: constants
private extension HomeCardFooterView {
    static let stackSpacing: CGFloat = 4
    static let footerElementLineLimit = 2
}
