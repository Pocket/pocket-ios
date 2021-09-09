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
    private var model: MainViewModel

    @Environment(\.source)
    private var source: Source

    @Environment(\.tracker)
    private var tracker: Tracker

    @Environment(\.uiContexts)
    private var contexts: [UIContext]

    init(model: MainViewModel) {
        self.model = model
    }

    private func background(item: Item) -> Color {
        if item.url == model.selectedItem?.url {
            return Color(ColorAsset.ui.grey6)
        } else {
            return Color.clear
        }
    }

    var body: some View {
        List {
            ForEach(content, id: \.1) { (index, item) in
                ItemListViewRow(item: item, model: model, index: index)
                    .trackable(.home.item(index: UInt(index)))
                    .swipeActions {
                        Button {
                            archive(item: item, index: index)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }.tint(Color(.branding.iris1))
                    }
                    .listRowBackground(background(item: item))
                    .environment(\.source, source)
            }
        }
        .refreshable {
            await source.refresh()
        }
        .trackable(.home.list)
        .listStyle(.plain)
        .accessibility(identifier: "user-list")
        .navigationTitle(Text("My List"))
    }

    private func archive(item: Item, index: Int) {
        source.archive(item: item)

        guard let url = item.url else {
            return
        }

        let contexts = self.contexts as [SnowplowContext] + [
            UIContext.home.item(index: UInt(index)),
            UIContext.button(identifier: .itemArchive),
            Content(url: url)
        ]

        tracker.track(
            event: Engagement(type: .general, value: nil),
            contexts
        )
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
    private var model: MainViewModel
    
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

    init(item: Item, model: MainViewModel, index: Int) {
        self.item = item
        self.model = model
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
            
            model.selectedItem = item
        }) {
            ItemRowView(
                model: ItemPresenter(
                    item: item,
                    index: index,
                    source: source,
                    tracker: tracker,
                    contexts: uiContexts
                )
            )
                .trackable(.home.item(index: UInt(index)))
                .onAppear {
                    let contexts = contexts
                    guard contexts.count > 1 else {
                        return
                    }
                    
                    let impression = Impression(component: .content, requirement: .instant)
                    tracker.track(event: impression, contexts)
                }
        }
    }
}
