// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct CardFooter: View {
    let card: HomeCardConfiguration
    let shareURL: String?
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

    @Environment(\.homeActions)
    var homeActions

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
                    homeActions.deleteAction(
                        givenURL: card.givenURL,
                        info: AnalyticsInfo(
                            type: card.type,
                            url: card.givenURL,
                            index: card.index
                        )
                    )
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
                    .style(.recommendation.domain)
                    .lineLimit(Self.footerElementLineLimit)
                    .accessibilityIdentifier("domain-label")
            }
            if let timeToRead, timeToRead > 0 {
                Text(makeTimeToRead(timeToRead))
                    .lineLimit(Self.footerElementLineLimit)
                    .accessibilityIdentifier("time-to-read-label")
            }
        }
    }

    func makeTimeToRead(_ timeToRead: Int32) -> AttributedString {
        AttributedString(
            NSAttributedString(
                string: Localization.Home.Recommendation.readTime(timeToRead),
                style: .recommendation.timeToRead
            )
        )
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
        if card.enableFavoriteAction {
            makeFavoriteButton()
        }
        if card.enableSaveAction {
            makeSaveButton()
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
            Haptics.defaultTap()
            homeActions.favoriteAction(
                isFavorite: isFavorite,
                givenURL: card.givenURL,
                info: AnalyticsInfo(
                    type: card.type,
                    url: card.givenURL,
                    index: card.index
                )
            )
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
            Haptics.defaultTap()
            homeActions.saveAction(
                isSaved: isSaved,
                givenURL: card.givenURL,
                info: AnalyticsInfo(
                    type: card.type,
                    url: card.givenURL,
                    index: card.index,
                    recommendationID: recommendationID
                )
            )
        }
        .accessibilityIdentifier("save-button")
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            if card.enableArchiveMenuAction {
                Button(
                    action: {
                        Haptics.defaultTap()
                        homeActions.archiveAction(
                            givenURL: card.givenURL,
                            info: AnalyticsInfo(
                                type: card.type,
                                url: card.givenURL,
                                index: card.index,
                                recommendationID: recommendationID
                            )
                        )
                    }
                ) {
                    Label {
                        Text(Localization.ItemAction.archive)
                    } icon: {
                        Image(asset: .archive)
                    }
                }
            }

            if card.enableDeleteMenuAction {
                Button(action: {
                    Haptics.defaultTap()
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
                    Haptics.defaultTap()
                    if recommendationID != nil {
                        showReportArticle = true
                    } else {
                        showReportError = true
                    }
                }) {
                    Label {
                        Text(Localization.ItemAction.report)
                    } icon: {
                        Image(asset: .alert)
                    }
                }
            }

            if card.enableShareMenuAction {
                ShareableURLView(givenURL: card.givenURL, shareURL: shareURL)
                    .simultaneousGesture(TapGesture().onEnded {
                        homeActions.trackShare(
                            AnalyticsInfo(
                                type: card.type,
                                url: card.givenURL,
                                index: card.index,
                                recommendationID: recommendationID
                            )
                        )
                    })
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
