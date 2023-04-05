// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile
import Localization

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

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
        }
        .sheet(isPresented: $viewModel.isPresentingHooray) {
            PremiumUpgradeSuccessView()
        }
        .onAppear {
            viewModel.trackOpenSearch()
        }
    }
}

// MARK: - Search Results Component
struct ResultsView: View {
    enum Constants {
        static let indexToTriggerNextPage = 15
    }

    @ObservedObject var viewModel: SearchViewModel

    let results: [PocketItem]

    @State private var showingAlert = false

    let swipeTintColor = Color(.ui.teal2)

    var body: some View {
        List {
            ForEach(Array(results.enumerated()), id: \.offset) { index, item in
                HStack {
                    ListItem(viewModel: viewModel.itemViewModel(item, index: index))
                    Spacer()
                }
                .swipeActions {
                    Button(viewModel.swipeActionTitle(item)) {
                        viewModel.handleSwipeAction(item, index: index)
                    }
                    .tint(swipeTintColor)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isOffline {
                        showingAlert = true
                    } else {
                        viewModel.select(item, index: index)
                    }
                }.onAppear {
                    let triggerNextPage = index == results.count - Constants.indexToTriggerNextPage
                    if triggerNextPage {
                        viewModel.loadMoreSearchResults(with: item, at: index)
                    }
                    viewModel.trackViewResults(url: item.url, index: index)
                }
            }
        }
        .zIndex(-1)
        .listStyle(.plain)
        .accessibilityIdentifier("search-results")
        .banner(data: viewModel.bannerData, show: $viewModel.showBanner, bottomOffset: 0)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(Localization.Search.Error.View.needsInternet), dismissButton: .default(Text("OK")))
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
                    if dismissReason == .system {
                        searchViewModel.isPresentingHooray = true
                    }
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
    @ObservedObject var viewModel: SearchViewModel
    var recentSearches: [String]

    var body: some View {
        List {
            Section(header: Text(Localization.Search.recent).style(.search.header)) {
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
