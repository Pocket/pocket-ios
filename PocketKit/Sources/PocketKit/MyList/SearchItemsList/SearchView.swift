// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    var body: some View {
        switch viewModel.searchState {
        case .emptyState(let viewModel):
            SearchEmptyView(viewModel: viewModel)
        case .recentSearches(let searches):
            RecentSearchView(viewModel: viewModel, recentSearches: searches)
        case .searchResults(let results):
            ResultsView(viewModel: viewModel, results: results)
        default:
            EmptyView()
        }
    }
}

// MARK: - Search Results Component
struct ResultsView: View {
    @ObservedObject
    var viewModel: SearchViewModel
    var results: [SearchItem]

    @State private var showingAlert = false

    let bannerData: BannerModifier.BannerData = BannerModifier.BannerData(image: .looking, title: "Limited search results", detail: "You can only search titles and URLs while offline. Connect to the internet to use Premium's full-text search.")

    var body: some View {
        List(results, id: \.id) { item in
            HStack {
                ListItem(model: item)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.isOffline {
                    showingAlert = true
                } else {
                    viewModel.select(item)
                }
            }.accessibilityIdentifier("search-results-item")
        }
        .zIndex(-1)
        .listStyle(.plain)
        .accessibilityIdentifier("search-results")
        .banner(data: bannerData, show: $viewModel.showBanner)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("You must have an internet connection to view this item."), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Search Empty States Component
struct SearchEmptyView: View {
    var viewModel: EmptyStateViewModel

    var body: some View {
        EmptyStateView(viewModel: viewModel)
            .padding(Margins.normal.rawValue)
    }
}

// MARK: - Recent Searches Component
struct RecentSearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel
    var recentSearches: [String]

    var body: some View {
        List {
            Section(header: Text("Recent Searches").style(.search.header)) {
                ForEach(recentSearches.reversed(), id: \.self) { recentSearch in
                    HStack {
                        Text(recentSearch)
                            .style(.search.row.default)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.searchText = recentSearch
                    }
                }
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("recent-searches")
    }
}
