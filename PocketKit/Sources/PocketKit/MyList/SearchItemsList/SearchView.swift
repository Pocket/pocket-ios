import SwiftUI
import Textile

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    var body: some View {
        if let results = viewModel.searchResults, !results.isEmpty {
            ResultsView(results: results)
        } else if viewModel.showRecentSearches == true, !viewModel.recentSearches.isEmpty {
            RecentSearchView(recentSearches: viewModel.recentSearches)
        } else if let emptyState = viewModel.emptyState {
            EmptyStateView(viewModel: emptyState)
                .padding(Margins.normal.rawValue)
        }
    }
}

struct ResultsView: View {
    var results: [SearchItem]

    var body: some View {
        NavigationView {
            List {
                ForEach(results, id: \.id) { item in
                    HStack {
                        // TODO: Fix Displaying Search Results
                        ItemDetail(title: item.title, detail: item.detail ?? "")
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier("search-results")
        }
    }
}

struct ItemDetail: View {
    var title: String
    var detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .style(.search.row.default)
            Text(detail)
                .style(.search.row.default)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding([.bottom, .trailing])
    }
}

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
