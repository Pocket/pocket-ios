// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    var body: some View {
        Group {
            switch viewModel.searchState {
            case .emptyState(let emptyStateViewModel):
                SearchEmptyView(viewModel: emptyStateViewModel)
                    .environmentObject(viewModel)
            case .recentSearches(let searches):
                RecentSearchView(viewModel: viewModel, recentSearches: searches)
            case .searchResults(let results):
                ResultsView(viewModel: viewModel, results: results)
            case .loading:
                SkeletonView()
            default:
                EmptyView()
            }
        }.onAppear {
            viewModel.trackOpenSearch()
        }
    }
}

// MARK: - Search Results Component
struct ResultsView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    let results: [PocketItem]

    @State private var showingAlert = false

    var body: some View {
        List {
            ForEach(Array(results.enumerated()), id: \.offset) { index, item in
                HStack {
                    ListItem(viewModel: viewModel.itemViewModel(item, index: index))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isOffline {
                        showingAlert = true
                    } else {
                        viewModel.select(item, index: index)
                    }
                }.onAppear {
                    viewModel.trackViewResults(url: item.url, index: index)
                }
            }
        }
        .zIndex(-1)
        .listStyle(.plain)
        .accessibilityIdentifier("search-results")
        .banner(data: viewModel.bannerData, show: $viewModel.showBanner)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(L10n.Search.Error.View.needsInternet), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Search Empty States Component
struct SearchEmptyView: View {
    private var viewModel: EmptyStateViewModel

    init(viewModel: EmptyStateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if let text = viewModel.buttonText {
            EmptyStateView(viewModel: viewModel) {
                GetPocketPremiumButton(text: text)
            }
            .padding(Margins.normal.rawValue)
        } else {
            EmptyStateView<EmptyView>(viewModel: viewModel)
                .padding(Margins.normal.rawValue)
        }
    }
}

struct GetPocketPremiumButton: View {
    @State var dismissReason: DismissReason = .swipe
    @EnvironmentObject private var searchViewModel: SearchViewModel
    private let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        Button(action: {
            searchViewModel.showPremiumUpgrade()
        }, label: {
            Text(text)
                .style(.header.sansSerif.h7.with(color: .ui.white))
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                .frame(maxWidth: 320)
        }).buttonStyle(GetPocketPremiumButtonStyle())
            .sheet(
                isPresented: $searchViewModel.isPresentingPremiumUpgrade,
                onDismiss: {
                    searchViewModel.trackPremiumDismissed(dismissReason: dismissReason)
            }
            ) {
                PremiumUpgradeView(dismissReason: self.$dismissReason, viewModel: searchViewModel.makePremiumUpgradeViewModel())
            }
            .task {
                searchViewModel.trackPremiumUpsellViewed()
            }
            .accessibilityIdentifier("get-pocket-premium-button")
    }
}

// MARK: - Recent Searches Component
struct RecentSearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel
    var recentSearches: [String]

    var body: some View {
        List {
            Section(header: Text(L10n.Search.recent).style(.search.header)) {
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
