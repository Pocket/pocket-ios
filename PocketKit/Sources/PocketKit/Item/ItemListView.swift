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

    init(selection: ItemSelection) {
        self.selection = selection
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
                Button(action: { selection.selectedItem = item }) {
                    ItemRowView(model: ItemPresenter(item: item))
                }.listRowBackground(background(item: item))
            }
        }
        .listStyle(.plain)
        .accessibility(identifier: "user-list")
        .navigationTitle(Text("My List"))
    }
}
