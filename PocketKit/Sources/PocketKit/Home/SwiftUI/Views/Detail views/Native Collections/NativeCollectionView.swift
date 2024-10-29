// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync

struct NativeCollectionView: View {
    let route: NativeCollectionRoute

    @Query private var collections: [Collection]
    private var collection: Collection? {
        collections.first
    }

    private var savedItem: SavedItem? {
        collection?.item?.savedItem
    }

    @Environment(\.homeActions)
    var homeActions

    var isSaved: Bool {
        savedItem != nil && savedItem?.isArchived == false
    }

    init(route: NativeCollectionRoute) {
        self.route = route
        var fetchDescriptor = FetchDescriptor(predicate: #Predicate<Collection> { $0.slug == route.slug })
        fetchDescriptor.fetchLimit = 1
        _collections = Query(fetchDescriptor)
    }

    var body: some View {
        if let collection, !collection.stories.isEmpty {
            CollectionStoriesView(
                slug: collection.slug,
                header: CollectionHeader(
                    title: collection.title,
                    intro: collection.intro,
                    numberOfItems: collection.stories.count,
                    author: getAuthors(from: collection)
                )
            )
            .toolbar {
                if let givenURL = collection.item?.givenURL {
                    ActionButton(
                        isActive: isSaved,
                        activeImage: .archive,
                        inactiveImage: .save,
                        highlightedColor: .ui.grey4,
                        activeColor: .ui.black1
                    ) {
                        homeActions.saveAction(isSaved: isSaved, givenURL: givenURL)
                    }
                    .accessibilityIdentifier("collection-save-button")
                }
                Button("Help") {
                    print("Help tapped!")
                }
            }
        } else {
            // TODO: SWIFTUI - Replace this with the loading animation
            Text("Loading Collection")
                .onAppear {
                    Task {
                        await homeActions.fetchCollection(slug: route.slug)
                    }
                }
        }
    }
}

private func getAuthors(from collection: Collection) -> String {
    if let item = collection.item, let authors = item.authors?.compactMap({ $0.name }) {
        return authors.joined()
    } else {
        return collection.authors.compactMap({ $0.name }).joined()
    }
}
