// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile
import CoreData
import Analytics

struct ItemListView: View {
    @FetchRequest(fetchRequest: Requests.fetchSavedItems())
    var items: FetchedResults<SavedItem>

    private var content: [(Int, SavedItem)] {
        return Array(zip(items.indices, items))
    }

    @ObservedObject
    private var model: MainViewModel

    @Environment(\.source)
    private var source: Source

    @Environment(\.tracker)
    private var tracker: Tracker

    init(model: MainViewModel) {
        self.model = model
    }

    private func background(item: SavedItem) -> Color {
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
                    .trackable(.myList.item(index: UInt(index)))
                    .swipeActions {
                        Button {
                            archive(item: item, index: index)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }.tint(Color(.branding.iris1))
                    }
                    .listRowSeparator(.visible, edges: [.bottom])
                    .listRowSeparator(.hidden, edges: [.top])
                    .listRowBackground(background(item: item))
                    .environment(\.source, source)
            }
        }
        .refreshable {
            await source.refresh()
        }
        .trackable(.myList.screen)
        .listStyle(.plain)
        .accessibility(identifier: "user-list")
        .navigationTitle(Text("My List"))
    }

    private func archive(item: SavedItem, index: Int) {
        source.archive(item: item)

        guard let url = item.url else {
            return
        }

        let contexts: [Context] = [
            UIContext.myList.item(index: UInt(index)),
            UIContext.button(identifier: .itemArchive),
            ContentContext(url: url)
        ]

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            contexts
        )
    }
}

private struct ItemListViewRow: View {
    @Environment(\.tracker)
    var tracker: Tracker

    @Environment(\.source)
    var source: Source
    
    @ObservedObject
    private var model: MainViewModel
    
    private let item: SavedItem
    
    private let index: Int

    init(item: SavedItem, model: MainViewModel, index: Int) {
        self.item = item
        self.model = model
        self.index = index
    }

    var body: some View {
        Button(action: {
            guard let itemURL = item.url else {
                return
            }
            
            let content = ContentContext(url: itemURL)
            let engagement = SnowplowEngagement(type: .general, value: nil)
            tracker.track(event: engagement, [content])
            
            model.selectedItem = item
            
            let open = ContentOpenEvent(destination: .internal, trigger: .click)
            tracker.track(event: open, [content])
        }) {
            ItemRowView(
                model: ItemPresenter(
                    item: item,
                    index: index,
                    source: source,
                    tracker: tracker
                )
            ).onAppear {
                guard let itemURL = item.url else {
                    return
                }
                
                let content = ContentContext(url: itemURL)
                let impression = ImpressionEvent(component: .content, requirement: .instant)
                tracker.track(event: impression, [content])
            }
        }.listRowBackground(Color(.ui.white1))
    }
}
