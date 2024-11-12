// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync

struct BoundedCell: Hashable {
    let inBounds: Bool
    let card: HomeCardConfiguration
}

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Environment(\.homeActions)
    private var homeActions

    @EnvironmentObject private var accessService: PocketAccessService

    @State private var trackableCells = Set<BoundedCell>()
    @State private var trackedCells = Set<BoundedCell>()

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 16)
                    if accessService.accessLevel.isAuthenticated {
                        RecentSavesView()
                        SharedWithYouView()
                    } else if accessService.accessLevel.isAnonymous {
                        SigninBannerView { accessService.requestAuthentication(.homeBanner) }
                            .padding()
                    }
                    RecommendationsView()
                }
            }
            .refreshable {
                await homeActions.refreshRecommendations(isForced: true)
            }
            .background(Color(.ui.white1))
            .navigationTitle(Localization.home)
            .environment(\.carouselWidth, carouselWidth(proxy.size))
            .environment(\.layoutWidth, layoutWidth(proxy.size))
            .overlayPreferenceValue(VisibleItemsPreference.self, { value in
                GeometryReader { proxy in
                    let myFrame = proxy.frame(in: .local)
                    let arr: [BoundedCell] = value.sorted(by: { $0.card.index < $1.card.index }).compactMap { boundedCard in
                        let inBounds = myFrame.intersects(proxy[boundedCard.bounds])
                        let element = BoundedCell(inBounds: inBounds, card: boundedCard.card)
                        if inBounds {
                            if trackableCells.contains(element) {
                                trackedCells.insert(element)
                            } else {
                                trackableCells.insert(element)
                                trackedCells.remove(element)
                            }
                            return (element)
                        } else {
                                trackableCells.remove(element)
                                trackedCells.remove(element)
                            return nil
                        }
                    }
                    let texts: [Text] = Array(trackableCells).map { boundedCard in
                        Text("\(boundedCard.card.index)")
                            .foregroundStyle(boundedCard.inBounds ? .primary : .secondary)
                    }

                    texts.joined(separator: Text(","))
                        .foregroundStyle(.white)
                        .background(.black)
                        .frame(maxHeight: .infinity)
                }
            })
        }
    }
}

extension [Text] {
    func joined(separator: Text) -> Text {
        guard let f = first else { return Text("") }
        return dropFirst().reduce(f, { $0 + separator + $1 })
    }
}

// MARK: environment setup
private extension HomeView {
    /// Determine the size of the current layout
    func layoutWidth(_ screenSize: CGSize) -> LayoutWidth {
        guard horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad else {
            return .compact
        }
        return screenSize.width > screenSize.height ? .extraWide : .wide
    }

    /// Calculate carousel cell width based on which layout is being used
    func carouselWidth(_ screenSize: CGSize) -> CGFloat {
        layoutWidth(screenSize).isRegular ? screenSize.width * 0.5 - 64 : screenSize.width * 0.8
    }
}
