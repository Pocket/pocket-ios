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
                    homeActions.setRecommendationsWidgetsOffline()
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
            .onChange(of: slates, initial: true) {
                homeActions.updateRecommendationsWidget()
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

    @ViewBuilder
    func makeSlatesView() -> some View {
        ForEach(slates) {
            if let recommendations = $0.recommendations, !recommendations.isEmpty {
                SlateView(
                    remoteID: $0.remoteID,
                    slateTitle: $0.name,
                    cards: cards(for: $0.remoteID)
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

    /// Fetch `Recommendation`s of the current `Slate`
    /// - Parameter slateID: `Slate` ID
    /// - Returns: the collection of `Recommendation`s, limited to 6 elements.
    func fetchRecommendations(_ slateID: String) -> [Recommendation] {
        let predicate = #Predicate<Recommendation> { $0.slate?.remoteID == slateID }
        let sortDescriptor = SortDescriptor<Recommendation>(\.sortIndex, order: .forward)
        var fetchDescriptor = FetchDescriptor<Recommendation>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 6

        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }

    /// Fetch an `Item` from the underlying `Recommendation`
    /// - Parameter recommendationID: `Recommendation` ID
    /// - Returns: the item, if it was found
    func fetchItem(_ recommendationID: String) -> Item? {
        let predicate = #Predicate<Item> { $0.recommendation?.remoteID == recommendationID }
        var fetchDescriptor = FetchDescriptor(predicate: predicate)
        fetchDescriptor.fetchLimit = 1

        let result = (try? modelContext.fetch(fetchDescriptor)) ?? []
        return result.first
    }

    func cards(for slateID: String) -> [HomeCardConfiguration] {
        fetchRecommendations(slateID)
            .compactMap {
                if let item = fetchItem($0.remoteID) {
                    return HomeCardConfiguration(
                        givenURL: item.givenURL,
                        sharedWithYouUrlString: nil,
                        type: .recommendation,
                        index: Int($0.sortIndex),
                        shareURL: item.shareURL,
                        domain: item.domain,
                        timeToRead: item.timeToRead,
                        isSyndicated: item.isSyndicated,
                        recommendationID: $0.analyticsID,
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
