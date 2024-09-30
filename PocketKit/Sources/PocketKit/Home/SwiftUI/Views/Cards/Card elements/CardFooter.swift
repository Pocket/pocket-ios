// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct CardFooter: View {
    let card: HomeCard
    let domain: String?
    let timeToRead: Int32?
    let isSaved: Bool
    let isFavorite: Bool
    let isSyndicated: Bool
    let recommendationID: String?

    @State private var showReportArticle: Bool = false
    @State private var showReportError: Bool = false

    @State private var showDeleteAlert: Bool = false

    @State private var showShareSheet: Bool = false

    var body: some View {
        makeFooter()
    }
}

// MARK: view builders
private extension CardFooter {
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
        .sheet(isPresented: $showReportArticle) {
            ReportRecommendationView(
                givenURL: card.givenURL,
                recommendationId: recommendationID!,
                tracker: Services.shared.tracker
           )
        }
        .alert(Localization.areYouSureYouWantToDeleteThisItem, isPresented: $showDeleteAlert) {
            Button(Localization.no, role: .cancel) { }
            Button(Localization.yes, role: .destructive) {
                withAnimation {
                    card.deleteAction()
                }
            }
        }
        .alert(Localization.General.Error.serverError, isPresented: $showReportError) {
            Button(Localization.ok, role: .cancel) { }
        }
    }

    /// Footer description
    func makeFooterDescription() -> some View {
        VStack(alignment: .leading, spacing: Self.stackSpacing) {
            if let domain {
                makeDomain(domain)
                    .style(card.domainStyle)
                    .lineLimit(Self.footerElementLineLimit)
                    .accessibilityIdentifier("domain-label")
            }
            if let timeToRead, timeToRead > 0 {
                Text(card.timeToRead(timeToRead))
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
            if card.enableFavoriteAction {
                makeFavoriteButton()
            }
            if card.enableSaveAction {
                makeSaveButton()
            }
        }
    }

    func makeFavoriteButton() -> some View {
        ActionButton(
            isActive: isFavorite,
            activeImage: .favoriteFilled,
            inactiveImage: .favorite,
            highlightedColor: .branding.amber1,
            activeColor: .branding.amber4,
            inactiveColor: .ui.grey8
        ) {
            card.favoriteAction(isFavorite: isFavorite, givenURL: card.givenURL)
        }
        .accessibilityIdentifier("favorite-button")
    }

    func makeSaveButton() -> some View {
        ActionButton(
            isActive: isSaved,
            activeImage: .saved,
            inactiveImage: .save,
            activeTitle: Localization.Recommendation.saved,
            inactiveTitle: Localization.Recommendation.save,
            highlightedColor: .ui.coral1,
            activeColor: .ui.coral2
        ) {
            card.saveAction(isSaved: isSaved)
        }
        .accessibilityIdentifier("save-button")
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            if card.enableArchiveMenuAction {
                Button(action: {
                    card.archiveAction()
                }) {
                    Text(Localization.ItemAction.archive)
                }
            }
            if card.enableDeleteMenuAction {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Label {
                        Text(Localization.ItemAction.delete)
                    } icon: {
                        Image(asset: .delete)
                    }
                }
            }
            if card.enableReportMenuAction {
                Button(action: {
                    if recommendationID != nil {
                        showReportArticle = true
                    } else {
                        showReportError = true
                    }
                }) {
                    Text(Localization.ItemAction.report)
                }
            }

            if card.enableShareMenuAction {
                ShareableURLView(card: card)
            }
        } label: {
            Image(asset: .overflow)
                .homeOverflowMenyStyle()
        }
        .accessibilityIdentifier("overflow-button")
    }
}

// MARK: constants
private extension CardFooter {
    static let stackSpacing: CGFloat = 4
    static let footerElementLineLimit = 2
}
