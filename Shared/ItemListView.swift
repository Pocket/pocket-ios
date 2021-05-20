// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync


struct ItemListView: View {
    @Environment(\.source)
    private var source: Source

    private let token: String
    
    @FetchRequest(fetchRequest: Requests.fetchItems())
    var items: FetchedResults<Item>

    init(token: String) {
        self.token = token
        source.refresh(token: token)
    }


    var body: some View {
        List(items) { item in
            NavigationLink(
                destination: ItemDestinationView(item: item)) {
                ItemView(item: item)
            }
        }.accessibility(identifier: "user-list")
    }
}

struct ItemView: View {
    @ObservedObject
    private var item: Item

    init(item: Item) {
        self.item = item
    }

    var body: some View {
        VStack {
            Text(item.title ?? "no-title")
            Text(item.url?.absoluteString ?? "no-url")
        }
    }
}

struct ItemDestinationView: View {
    let item: Item
    
    var body: some View {
        ReaderView(item: item)
            .navigationBarTitle(item.title ?? "Reader", displayMode: .inline)
            .accessibility(identifier: "web-reader")
    }
}
