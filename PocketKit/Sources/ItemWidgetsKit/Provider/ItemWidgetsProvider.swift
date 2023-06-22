// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Sync
import SwiftUI
import Textile
import WidgetKit

/// Timeline provider for the recent saves widget
struct ItemWidgetsProvider: TimelineProvider {
    let service: ItemWidgetsService?
    let tracker: WidgetTracker?

    init(service: ItemWidgetsService?, tracker: WidgetTracker?) {
        self.service = service
        self.tracker = tracker
        Textiles.initialize()
    }

    private var kind: ItemWidgetKind {
        service?.kind ?? .unknown
    }

    private var emptyContentType: ItemsListContentType {
        switch kind {
        case .recentSaves:
            return .recentSavesEmpty
        case .recommendations:
            return .recommendationsEmpty
        case .unknown:
            return .error
        }
    }

    func placeholder(in context: Context) -> ItemsListEntry {
        ItemsListEntry(date: Date(), name: "", contentType: .items([ItemRowContent(content: .placeHolder, image: nil)]))
    }

    func getSnapshot(in context: Context, completion: @escaping (ItemsListEntry) -> Void) {
        guard let service else {
            Log.capture(message: "Item widget: unable to initialize service")
            completion(ItemsListEntry(date: Date(), name: "", contentType: .error))
            return
        }
        // logged out
        guard service.isLoggedIn else {
            completion(ItemsListEntry(date: Date(), name: "", contentType: .loggedOut))
            return
        }
        let items = service.getItems(limit: numberOfItems(for: context.family))
        // empty result
        // TODO: pick the first item in the array once we refactor
        guard !items.isEmpty else {
            completion(ItemsListEntry(date: Date(), name: "", contentType: emptyContentType))
            return
        }
        Task {
            let contentWithImages = await getContentWithImages(content: items.items)
            completion(ItemsListEntry(date: Date(), name: items.name, contentType: .items(contentWithImages)))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ItemsListEntry>) -> Void) {
        guard let service else {
            Log.capture(message: "Item widget: unable to initialize service")
            let timeline = Timeline(entries: [ItemsListEntry(date: Date(), name: "", contentType: .error)], policy: .never)
            completion(timeline)
            return
        }
        guard service.isLoggedIn else {
            let entries = [ItemsListEntry(date: Date(), name: "", contentType: .loggedOut)]
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
            return
        }
        let items = service.getItems(limit: numberOfItems(for: context.family))
        // empty result
        guard !items.isEmpty else {
            let entries = [ItemsListEntry(date: Date(), name: "", contentType: emptyContentType)]
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
            return
        }
        Task {
            let contentWithImages = await getContentWithImages(content: items.items)
            // TODO: add logic to calculate the dates for each entry and the date to pass to the policy
            var date = Date()
            let entriesWithImages = [ItemsListEntry(date: date, name: items.name, contentType: .items(contentWithImages))]
            let timeline = Timeline(entries: entriesWithImages, policy: policy(date: date))
            completion(timeline)
        }

        // TODO: Gets triggered when installing, but not removing a widget
        tracker?.getWidgetConfigurations()
    }
}

// MARK: content configuration
private extension ItemWidgetsProvider {
    /// Returns the number of recent saves to display for a given widget family
    /// - Parameter widgetFamily: the given widget family
    /// - Returns: the number of recent saves
    func numberOfItems(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemLarge:
            return 4
        case .systemMedium:
            return 2
        default:
            // We will need to add values if we support other categories in the future
            return SyncConstants.Home.recentSaves
        }
    }

    func policy(date: Date) -> TimelineReloadPolicy {
        switch kind {
        case .recentSaves, .unknown:
            return .never
        case .recommendations:
            return .after(date)
        }
    }
}

// MARK: download thumbnails
private extension ItemWidgetsProvider {
    /// Default resolution for downloaded thumbnails, with native aspect ratio of 4/3
    static let defaultThumbnailResolution = CGSize(width: 320, height: 240)

    /// Download thumbnails, attach them to the related item and return the updated list of recent `[SavedItemRowContent]`
    /// - Parameter content: the recent saves without thumbnails `[SavedItemContent]`
    /// - Returns: the updated list
    func getContentWithImages(content: [ItemContent]) async -> [ItemRowContent] {
        return await withTaskGroup(of: ItemRowContent.self, returning: [ItemRowContent].self) { taskGroup in
            content.forEach { item in
                taskGroup.addTask {
                    await downloadImage(for: item)
                }
            }
            // we need to update the content in the existing order,
            // because we don't know when each task will complete.
            let orderedContent = content.map { ItemRowContent(content: $0, image: nil) }
            return await taskGroup.reduce(into: orderedContent) { orderedContent, item in
                if let index = orderedContent.firstIndex(where: { $0.content == item.content }) {
                    orderedContent[index] = item
                }
            }
        }
    }

    /// Downloads the thumbnail for a given `SavedItemRowContent` item
    /// - Parameter item: the given item
    /// - Returns: the updated item with the downloaded image, or the original content, if no thumbnail was found.
    func downloadImage(for item: ItemContent) async -> ItemRowContent {
        guard let imageUrl = item.imageUrl, let url = URL(string: imageUrl) else {
            return ItemRowContent(content: item, image: nil)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: bestURL(for: url))
            guard let uiImage = UIImage(data: data) else {
                return ItemRowContent(content: item, image: nil)
            }
            return ItemRowContent(content: item, image: Image(uiImage: uiImage))
        } catch {
            Log.capture(message: "Item widget: unable to download thumbnail - \(error)")
            return ItemRowContent(content: item, image: nil)
        }
    }

    /// Returns the CDN URL to download an image of a given size
    /// - Parameters:
    ///   - url: the original url
    ///   - size: the given size. Defaults to the provider default resolution
    /// - Returns: the CDN URL or the original URL, if no CDN URL was found
    func bestURL(
        for url: URL,
        size: CGSize = CGSize(
            width: Self.defaultThumbnailResolution.width,
            height: Self.defaultThumbnailResolution.height
        )
    ) -> URL {
        let builder = CDNURLBuilder()
        return builder.imageCacheURL(for: url, size: size) ?? url
    }
}
