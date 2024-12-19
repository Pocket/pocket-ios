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

    @State private var viewState: ViewState = .loading

    @Query(sort: \Slate.sortIndex, order: .forward)
    private var slates: [Slate]

    @StateObject private var networkMonitor: NetworkMonitor

    @Environment(\.homeActions)
    private var homeActions

    @Environment(\.modelContext)
    private var modelContext

    init() {
        _networkMonitor = StateObject(wrappedValue: NetworkMonitor())
    }

    var body: some View {
        makeBody()
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
    private func makeBody() -> some View {
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
    private func slateInfo(_ slate: Slate) -> SlateInfo? {
        guard let lineup = slate.slateLineup else { return nil }
        return SlateInfo(
            slateId: slate.remoteID,
            slateRequestId: slate.requestID,
            slateExperimentId: slate.experimentID,
            slateIndex: Int(slate.sortIndex ?? 0),
            slateLineupId: lineup.remoteID,
            slateLineupRequestId: lineup.requestID,
            slateLineupExperimentId: lineup.experimentID
        )
    }
    @ViewBuilder
    func makeSlatesView() -> some View {
        ForEach(slates) {
            if let recommendations = $0.recommendations, !recommendations.isEmpty {
                SlateView(
                    remoteID: $0.remoteID,
                    slateTitle: $0.name,
                    cards: cards(for: $0.remoteID),
                    slateInfo: slateInfo($0)
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

    func cards( for slateID: String) -> [HomeCardConfiguration] {
        let predicate = #Predicate<Recommendation> { $0.slate?.remoteID == slateID }
        let sortDescriptor = SortDescriptor<Recommendation>(\.sortIndex, order: .forward)
        var fetchDescriptor = FetchDescriptor<Recommendation>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 6

        let recommendations = (try? modelContext.fetch(fetchDescriptor)) ?? []

        return recommendations
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
