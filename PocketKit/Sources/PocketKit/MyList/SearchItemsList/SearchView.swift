import SwiftUI
import Textile

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    var body: some View {
        if viewModel.showRecentSearches == true, !viewModel.recentSearches.isEmpty {
            RecentSearchView(recentSearches: viewModel.recentSearches)
        } else if let emptyState = viewModel.emptyState {
            EmptyStateView(viewModel: emptyState)
                .padding(Margins.normal.rawValue)
        }
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
