// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile
import CoreData

struct ItemListView: View {
    @FetchRequest(fetchRequest: Requests.fetchItems())
    var items: FetchedResults<Item>

    @ObservedObject
    private var selection: ItemSelection

    private let source: Source

    init(selection: ItemSelection, source: Source) {
        self.selection = selection
        self.source = source
    }

    func background(item: Item) -> Color {
        if item.url == selection.selectedItem?.url {
            return Color(ColorAsset.ui.grey6)
        } else {
            return Color.clear
        }
    }

    var body: some View {
        List {
            ForEach(items) { item in
                Button {
                    selection.selectedItem = item
                }
                label: {
                    ItemRowView(model: ItemPresenter(item: item))
                }
                .swipeActions {
                    favoriteButton(for: item)
                        .tint(Color(.branding.amber3))
                }
                .listRowBackground(background(item: item))
            }
        }
        .listStyle(.plain)
        .accessibility(identifier: "user-list")
        .navigationTitle(Text("My List"))
    }

    @ViewBuilder
    private func favoriteButton(for item: Item) -> some View {
        if item.isFavorite {
            Button {
                source.unfavorite(item: item)
            } label: {
                Label("Unfavorite", systemImage: "star.slash")
            }
        } else {
            Button {
                source.favorite(item: item)
            } label: {
                Label("Favorite", systemImage: "star")
            }
        }
    }
}
