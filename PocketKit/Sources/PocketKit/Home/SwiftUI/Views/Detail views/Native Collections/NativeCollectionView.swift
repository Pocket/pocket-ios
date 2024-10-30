// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct NativeCollectionView: View {
    let destination: NativeCollectionDestination

    @State private var showDeleteAlert: Bool = false
    @State private var showReportError: Bool = false
    @State private var showReportArticle: Bool = false

    @Query private var fetchedItem: [Item]
    private var item: Item? {
        fetchedItem.first
    }
    private var collection: Collection? {
        item?.collection
    }
    private var recommendationID: String? {
        item?.recommendation?.analyticsID
    }

    @Query private var fetchedSavedItem: [SavedItem]
    private var savedItem: SavedItem? {
        fetchedSavedItem.first
    }
    private var isSaved: Bool {
        savedItem != nil && savedItem?.isArchived == false
    }

    @Environment(\.homeActions)
    var homeActions

    @EnvironmentObject var navigation: HomeNavigation

    init(destination: NativeCollectionDestination) {
        self.destination = destination
        let givenURL = destination.givenURL

        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenURL })
        itemDescriptor.fetchLimit = 1
        _fetchedItem = Query(itemDescriptor, animation: .easeIn)

        var savedItemDescriptor = FetchDescriptor<SavedItem>(predicate: #Predicate<SavedItem> { $0.item?.givenURL == givenURL })
        savedItemDescriptor.fetchLimit = 1
        _fetchedSavedItem = Query(savedItemDescriptor, animation: .easeIn)
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
            .sheet(isPresented: $showReportArticle) {
                ReportRecommendationView(
                    givenURL: destination.givenURL,
                    recommendationId: recommendationID!,
                    tracker: Services.shared.tracker
               )
            }
            .alert(Localization.areYouSureYouWantToDeleteThisItem, isPresented: $showDeleteAlert) {
                Button(Localization.no, role: .cancel) { }
                Button(Localization.yes, role: .destructive) {
                    withAnimation {
                        homeActions.deleteAction(givenURL: destination.givenURL)
                    }
                }
            }
            .alert(Localization.General.Error.serverError, isPresented: $showReportError) {
                Button(Localization.ok, role: .cancel) { }
            }
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
                        if isSaved {
                            navigation.back()
                        }
                    }
                    .accessibilityIdentifier("collection-save-button")
                }
                makeOverflowMenu()
            }
        } else {
            // TODO: SWIFTUI - Replace this with the loading animation
            Text("Loading Collection")
                .onAppear {
                    Task {
                        await homeActions.fetchCollection(slug: destination.slug)
                    }
                }
        }
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            if isSaved {
                Button(action: {
                    Haptics.defaultTap()
                    homeActions.archiveAction(givenURL: destination.givenURL)
                    navigation.back()
                }) {
                    Label {
                        Text(Localization.ItemAction.archive)
                    } icon: {
                        Image(asset: .archive)
                    }
                }
            }

            if savedItem != nil {
                Button(action: {
                    Haptics.defaultTap()
                    showDeleteAlert = true
                }) {
                    Label {
                        Text(Localization.ItemAction.delete)
                    } icon: {
                        Image(asset: .delete)
                    }
                }
            }

            if savedItem != nil {
                Button(action: {
                    Haptics.defaultTap()
                    if recommendationID != nil {
                        showReportArticle = true
                    } else {
                        showReportError = true
                    }
                }) {
                    Label {
                        Text(Localization.ItemAction.report)
                    } icon: {
                        Image(asset: .alert)
                    }
                }
            }

            ShareableURLView(givenURL: destination.givenURL, shareURL: item?.shareURL)
        } label: {
            Image(asset: .overflow)
                .homeOverflowMenyStyle()
        }
        .accessibilityIdentifier("overflow-button")
    }

    private func getAuthors(from collection: Collection) -> String {
        if let item = collection.item, let authors = item.authors?.compactMap({ $0.name }) {
            return authors.joined()
        } else {
            return collection.authors.compactMap({ $0.name }).joined()
        }
    }
}
