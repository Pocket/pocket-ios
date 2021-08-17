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

    @Environment(\.source)
    private var source: Source

    init(selection: ItemSelection) {
        self.selection = selection
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
                        Button {
                            source.archive(item: item)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }.tint(Color(.branding.iris1))
                    }
                    .listRowBackground(background(item: item))
                    .environment(\.source, source)
            }
        }
        .trackable(.home.list)
        .listStyle(.plain)
        .accessibility(identifier: "user-list")
        .navigationTitle(Text("My List"))
    }
}

private struct ItemListViewRow: View {
    @Environment(\.uiContexts)
    var uiContexts: [UIContext]
    
    @Environment(\.tracker)
    var tracker: Tracker

    @Environment(\.source)
    var source: Source
    
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
            ItemRowView(model: ItemPresenter(item: item, index: index, source: source))
                .onAppear {
                    let impression = Impression(component: .content, requirement: .instant)
                    tracker.track(event: impression, contexts)
                }
        }
    }
}
