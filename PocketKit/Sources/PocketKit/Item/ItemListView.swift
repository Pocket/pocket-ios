// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile
import CoreData
import Analytics

struct ItemListView: View {
    @FetchRequest(fetchRequest: Requests.fetchItems())
    var items: FetchedResults<Item>

    private var content: [(Int, Item)] {
        return Array(zip(items.indices, items))
    }

    @ObservedObject
    private var selection: ItemSelection

    private let source: Source

    init(selection: ItemSelection, source: Source) {
        self.selection = selection
        self.source = source
    }

    private func background(item: Item) -> Color {
        if item.url == selection.selectedItem?.url {
            return Color(ColorAsset.ui.grey6)
        } else {
            return Color.clear
        }
    }

    var body: some View {
        List {
            ForEach(content, id: \.1) { (index, item) in
                ItemListViewRow(item: item, selection: selection, index: index)
                    .trackable(.home.item(index: UInt(index)))
                    .swipeActions {
                        favoriteButton(for: item)
                            .tint(Color(.branding.amber3))
                        Button {
                            source.delete(item: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.tint(.red)
                    }
                    .listRowBackground(background(item: item))
            }
        }
        .trackable(.home.list)
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

private struct ItemListViewRow: View {
    @Environment(\.uiContexts)
    var uiContexts: [UIContext]
    
    @Environment(\.tracker)
    var tracker: Tracker
    
    @ObservedObject
    private var selection: ItemSelection
    
    private let item: Item
    
    private let index: Int
    
    private var contexts: [SnowplowContext] {
        guard let itemURL = item.url else {
            return []
        }
        
        let content = Content(url: itemURL)
        let contexts: [SnowplowContext] = uiContexts + [content]
        return contexts
    }

    init(item: Item, selection: ItemSelection, index: Int) {
        self.item = item
        self.selection = selection
        self.index = index
    }

    var body: some View {
        Button(action: {
            if let url = item.url {
                let open = ContentOpen(destination: .internal, trigger: .click)
                let content = Content(url: url)
                let contexts: [SnowplowContext] = uiContexts + [content]
                tracker.track(event: open, contexts)
            }
            
            selection.selectedItem = item
        }) {
            ItemRowView(model: ItemPresenter(item: item, index: index))
                .onAppear {
                    let impression = Impression(component: .content, requirement: .instant)
                    tracker.track(event: impression, contexts)
                }
        }
    }
}
