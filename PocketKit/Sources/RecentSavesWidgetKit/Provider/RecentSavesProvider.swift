// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Sync
import SwiftUI
import WidgetKit

enum RecentSavesProviderError: Error {
    case invalidStore
}

/// Timeline provider for the recent saves widget
struct RecentSavesProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecentSavesEntry {
        RecentSavesEntry(date: Date(), content: [SavedItemRowContent(content: .placeHolder, image: nil)])
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentSavesEntry) -> Void) {
        do {
            let saves = try getRecentSaves(for: context.family)
            // TODO: handle task result
            Task {
                let contentWithImages = try await getContentWithImages(content: saves)
                completion(RecentSavesEntry(date: Date(), content: contentWithImages))
            }
        } catch {
            Log.capture(message: "Unable to read saved items from shared useer defaults")
            // TODO: Handle error scenario here
            completion(RecentSavesEntry(date: Date(), content: [SavedItemRowContent(content: .placeHolder, image: nil)]))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentSavesEntry>) -> Void) {
        do {
            let saves = try getRecentSaves(for: context.family)
            // TODO: handle task result
            Task {
                let contentWithImages = try await getContentWithImages(content: saves)
                let entriesWithImages = [RecentSavesEntry(date: Date(), content: contentWithImages)]
                let timeline = Timeline(entries: entriesWithImages, policy: .never)
                completion(timeline)
            }
        } catch {
            Log.capture(message: "Unable to read saved items from shared useer defaults")
            // TODO: Handle error scenario here
            let timeline = Timeline(entries: [RecentSavesEntry](), policy: .never)
            completion(timeline)
        }
    }

    private func getContentWithImages(content: [SavedItemContent]) async throws -> [SavedItemRowContent] {
        let orderedContent = content.map { SavedItemRowContent(content: $0, image: nil) }
        return try await withThrowingTaskGroup(of: SavedItemRowContent.self, returning: [SavedItemRowContent].self) { taskGroup in

            content.forEach { item in
                    taskGroup.addTask {
                        try await downloadImage(for: item)
                    }
            }

            return try await taskGroup.reduce(into: orderedContent) { orderedContent, item in
                if let index = orderedContent.firstIndex(where: { $0.content == item.content }) {
                    orderedContent[index] = item
                }
            }
        }
    }

    /// Downloads the thumbnail for a given `SavedItemRowContent` item
    /// - Parameter item: the given item
    /// - Returns: the updated item with the downloaded image, if any.
    private func downloadImage(for item: SavedItemContent) async throws -> SavedItemRowContent {
        guard let imageUrl = item.imageUrl, let url = URL(string: imageUrl) else {
            return SavedItemRowContent(content: item, image: nil)
        }
        let (data, _) = try await URLSession.shared.data(from: bestURL(for: url))
        guard let uiImage = UIImage(data: data) else {
            return SavedItemRowContent(content: item, image: nil)
        }

        return SavedItemRowContent(content: item, image: Image(uiImage: uiImage))
    }

    /// Returns the CDN URL to download an image of a given size
    /// - Parameters:
    ///   - url: the original url
    ///   - size: the given size
    /// - Returns: the CDN URL or the original URL, if no CDN URL was found
    private func bestURL(for url: URL, size: CGSize = CGSize(width: 48, height: 36)) -> URL {
        let builder = CDNURLBuilder()
        return builder.imageCacheURL(for: url, size: size) ?? url
    }

    /// Returns the number of recent saves to display for a given widget family
    /// - Parameter widgetFamily: the given widget family
    /// - Returns: the number of recent saves
    private func numberOfItems(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemExtraLarge:
            return 0
        case .systemLarge:
            return 4
        case .systemMedium:
            return 2
        default:
            return 1
        }
    }

    /// Retrieves the recent saves for a given widget family
    /// - Parameter widgetFamily: the given widget family
    /// - Returns: the list of recent saves in a `[SavedItemContent]` array
    private func getRecentSaves(for widgetFamily: WidgetFamily) throws -> [SavedItemContent] {
        guard let defaults = UserDefaults(suiteName: "group.com.ideashower.ReadItLaterPro") else {
            throw RecentSavesProviderError.invalidStore
        }
        let service = RecentSavesWidgetService(store: RecentSavesWidgetStore(userDefaults: defaults))

        return service.getRecentSaves(limit: numberOfItems(for: widgetFamily))
    }
}
