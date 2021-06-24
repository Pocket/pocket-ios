// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile

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
            ZStack(alignment: .leading) {
                NavigationLink(
                    destination: ItemDestinationView(item: item)
                ) { EmptyView() }

                ItemRowView(model: ItemPresenter(item: item))
            }
        }.accessibility(identifier: "user-list")
    }
}
