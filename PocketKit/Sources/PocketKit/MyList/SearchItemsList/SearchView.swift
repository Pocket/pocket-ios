import SwiftUI
import Textile

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel
    var showTempResultsView: Bool = false

    var body: some View {
        if let results = viewModel.searchResults, !results.isEmpty {
            ResultsView(results: results)
        } else if viewModel.showRecentSearches == true, !viewModel.recentSearches.isEmpty {
            RecentSearchView(recentSearches: viewModel.recentSearches)
        } else if let emptyState = viewModel.emptyState {
            SearchEmptyView(viewModel: emptyState)
        }
    }
}

// MARK: - Search Results Component
struct ResultsView: View {
    var results: [SearchItem]
    var body: some View {
        List {
            ForEach(results, id: \.id) { item in
                HStack {
                    ListItem(model: item)
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("search-results")
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
                        // TODO: Handle recent search tap
                    }
                }
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("recent-searches")
    }
}
