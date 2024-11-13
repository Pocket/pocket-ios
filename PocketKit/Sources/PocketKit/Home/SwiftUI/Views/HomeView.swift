// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Environment(\.homeActions)
    private var homeActions

    @EnvironmentObject private var accessService: PocketAccessService

    @StateObject private var cellTracker: CellImpressionTracker

    init() {
        _cellTracker = StateObject(wrappedValue: CellImpressionTracker())
    }

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
                    let newTrackableCells = trackableCells(value, proxy)
                    if cellTracker.cells != newTrackableCells {
                            cellTracker.cells = newTrackableCells
                        }
                    return Color.clear
                }
            })
        }
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

// MARK: impression tracking
private extension HomeView {
    /// Extracts the trackable cells based on the set of visible cells contained in the preference key value and the current geometry frame.
    func trackableCells(_ visibleCells: [GeometryCard], _ proxy: GeometryProxy) -> Set<HomeCardConfiguration> {
        let currentFrame = proxy.frame(in: .local)
        let arrayOfCells: [HomeCardConfiguration] = visibleCells
            .filter({ currentFrame.intersects(proxy[$0.bounds]) })
            .map({ $0.card })
        return Set(arrayOfCells)
    }
}
