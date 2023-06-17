// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Sync
import SwiftUI
import Textile
import WidgetKit

enum RecentSavesProviderError: Error {
    case invalidStore
}

/// Timeline provider for the recent saves widget
struct RecentSavesProvider: TimelineProvider {
    init() {
        Textiles.initialize()
    }

    func placeholder(in context: Context) -> ItemsListEntry {
        ItemsListEntry(date: Date(), contentType: .items([ItemRowContent(content: .placeHolder, image: nil)]))
    }

    func getSnapshot(in context: Context, completion: @escaping (ItemsListEntry) -> Void) {
        do {
            let service = try makeService()
            // logged out
            guard service.isLoggedIn else {
                completion(ItemsListEntry(date: Date(), contentType: .loggedOut))
                return
            }
            let saves = service.getRecentSaves(limit: numberOfItems(for: context.family))
            // empty result
            guard !saves.isEmpty else {
                completion(ItemsListEntry(date: Date(), contentType: .empty))
                return
            }
            Task {
                let contentWithImages = await getContentWithImages(content: saves)
                completion(ItemsListEntry(date: Date(), contentType: .items(contentWithImages)))
            }
        } catch {
            Log.capture(message: "Recent Saves widget: unable to initialize service - \(error)")
            completion(ItemsListEntry(date: Date(), contentType: .error))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ItemsListEntry>) -> Void) {
        do {
            let service = try makeService()
            // logged out
            guard service.isLoggedIn else {
                let entries = [ItemsListEntry(date: Date(), contentType: .loggedOut)]
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
                return
            }
            let saves = service.getRecentSaves(limit: numberOfItems(for: context.family))
            // empty result
            guard !saves.isEmpty else {
                let entries = [ItemsListEntry(date: Date(), contentType: .empty)]
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
                return
            }
            Task {
                let contentWithImages = await getContentWithImages(content: saves)
                let entriesWithImages = [ItemsListEntry(date: Date(), contentType: .items(contentWithImages))]
                let timeline = Timeline(entries: entriesWithImages, policy: .never)
                completion(timeline)
            }
        } catch {
            Log.capture(message: "Recent Saves widget: unable to initialize service - \(error)")
            let timeline = Timeline(entries: [ItemsListEntry(date: Date(), contentType: .error)], policy: .never)
            completion(timeline)
        }
    }
}

// MARK: read recent saves
extension RecentSavesProvider {
    /// Returns the number of recent saves to display for a given widget family
    /// - Parameter widgetFamily: the given widget family
    /// - Returns: the number of recent saves
    private func numberOfItems(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemLarge:
            return 4
        case .systemMedium:
            return 2
        default:
            // We will need to add values if we support other categories in the future
            return 0
        }
    }

    /// Builds an instance of `RecentSavesWidgetService`
    /// - Returns: the instance
    private func makeService() throws -> RecentSavesWidgetService {
        let defaults = try makeUserDefaults()
        return RecentSavesWidgetService(store: RecentSavesWidgetStore(userDefaults: defaults))
    }

    /// Returns the shared `UserDefaults` for the given build configuration
    private func makeUserDefaults() throws -> UserDefaults {
        guard let info = Bundle.main.infoDictionary,
                let groupID = info["GroupId"] as? String,
                let defaults = UserDefaults(suiteName: groupID) else {
            throw RecentSavesProviderError.invalidStore
        }
        return defaults
    }
}

// MARK: download thumbnails
extension RecentSavesProvider {
    /// Default size for downloaded thumbnails
    static let defaultThumbnailSize = CGSize(width: 80, height: 80)

    /// Download thumbnails, attach them to the related item and return the updated list of recent `[SavedItemRowContent]`
    /// - Parameter content: the recent saves without thumbnails `[SavedItemContent]`
    /// - Returns: the updated list
    private func getContentWithImages(content: [ItemContent]) async -> [ItemRowContent] {
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
    private func downloadImage(for item: ItemContent) async -> ItemRowContent {
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
            Log.capture(message: "Recent Saves widget: unable to download thumbnail - \(error)")
            return ItemRowContent(content: item, image: nil)
        }
    }

    /// Returns the CDN URL to download an image of a given size
    /// - Parameters:
    ///   - url: the original url
    ///   - size: the given size. Defaults to 3 times the provider default size for better image quality
    /// - Returns: the CDN URL or the original URL, if no CDN URL was found
    private func bestURL(
        for url: URL,
        size: CGSize = CGSize(
            width: Self.defaultThumbnailSize.width * 3,
            height: Self.defaultThumbnailSize.height * 3
        )
    ) -> URL {
        let builder = CDNURLBuilder()
        return builder.imageCacheURL(for: url, size: size) ?? url
    }
}
