// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Textile
import SwiftData
import SwiftUI
import Sync

struct RecommendationsView: View {
    private enum ViewState {
        case loading
        case ready
        case offline
    }

    @State private var viewState: ViewState = .ready

    @Query(sort: \Slate.sortIndex, order: .forward)
    private var slates: [Slate]

    @StateObject private var networkMonitor: NetworkMonitor

    @Environment(\.homeActions)
    private var homeActions

    init() {
        _networkMonitor = StateObject(wrappedValue: NetworkMonitor())
    }

    var body: some View {
        VStack(spacing: 32) {
            switch viewState {
            case .loading:
                if slates.isEmpty {
                    makeLoadingView()
                } else {
                    makeSlatesView()
                }
            case .ready:
                if slates.isEmpty {
                    makeOfflineView()
                } else {
                    makeSlatesView()
                }
            case .offline:
                makeOfflineView()
            }
        }
        .task {
            networkMonitor.start()
            guard viewState != .loading else { return }
            viewState = .loading
            await homeActions.refreshRecommendations()
            viewState = .ready
        }
        .onChange(of: networkMonitor.status, initial: true) { oldStatus, newStatus in
            guard oldStatus != newStatus else { return }
            switch newStatus {
            case .unsatisfied, .requiresConnection:
                viewState = .offline
            case .satisfied:
                viewState = .loading
                Task {
                    await homeActions.refreshRecommendations()
                    viewState = .ready
                }
            default:
                break
            }
        }
        .onDisappear {
            networkMonitor.cancel()
        }
    }
}

// MARK: view builders and helpers
private extension RecommendationsView {
    @ViewBuilder
    func makeSlatesView() -> some View {
        ForEach(slates) {
            if let recommendations = $0.recommendations, !recommendations.isEmpty {
                SlateView(
                    remoteID: $0.remoteID,
                    slateTitle: $0.name,
                    cards: cards(for: recommendations)
                )
            }
        }
    }

    func makeLoadingView() -> some View {
        LoadingView.loadingIndicator(Localization.LoadingView.message)
    }

    func makeOfflineView() -> some View {
        OfflineView()
    }

    func cards( for recommendations: [Recommendation]) -> [HomeCardConfiguration] {
        recommendations
            .sorted(by: { $0.sortIndex < $1.sortIndex })
            .prefix(6)
            .compactMap {
            if let item = $0.item {
                return HomeCardConfiguration(
                    givenURL: item.givenURL,
                    sharedWithYouUrlString: nil,
                    type: .recommendation,
                    index: Int(item.recommendation?.sortIndex ?? 0), // sortIndex should not be nil, but just in case, let's have a default
                    shareURL: item.shareURL,
                    domain: item.bestDomain,
                    timeToRead: item.timeToRead,
                    isSyndicated: item.isSyndicated,
                    recommendationID: item.recommendation?.analyticsID,
                    bestTitle: item.bestTitle,
                    slug: item.collectionSlug,
                    excerpt: item.excerpt,
                    topImageURL: item.topImageURL,
                    enableSaveAction: true,
                    enableShareMenuAction: true,
                    enableReportMenuAction: true
                )
            }
            return nil
        }
    }
}
