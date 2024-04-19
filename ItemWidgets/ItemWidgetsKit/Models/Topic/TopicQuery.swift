// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppIntents
import SharedPocketKit
import Sync
import UIKit
import SwiftUI

struct TopicQuery: EntityQuery {
    private var service: ItemWidgetsService? {
        ItemWidgetsService.makeRecommendationsService()
    }

    private func storedEntities() async -> [TopicEntity] {
        // Error
        guard let service else {
            Log.capture(message: "Item widget: unable to initialize service")
            return [TopicEntity(topic: ItemsWidgetContent(name: "", contentType: .error))]
        }
        // Logged out
        guard service.isLoggedIn else {
            return [TopicEntity(topic: ItemsWidgetContent(name: "", contentType: .loggedOut))]
        }
        let topics = service.getTopics(limit: 4)

        // Empty result
        guard !topics.isEmpty else {
            return [TopicEntity(topic: ItemsWidgetContent(name: "", contentType: .recommendationsEmpty))]
        }

        return await getEntriesWithImages(topics)
    }

    func entities(for identifiers: [TopicEntity.ID]) async throws -> [TopicEntity] {
        return await storedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [TopicEntity] {
        return await storedEntities()
    }

    func defaultResult() async -> TopicEntity? {
        return try? await suggestedEntities().first ?? TopicEntity(topic: .sampleContent)
    }
}

// MARK: thumbnails fetch
private extension TopicQuery {
    func getEntriesWithImages(_ topics: [ItemContentContainer]) async -> [TopicEntity] {
        return await withTaskGroup(of: (String, [ItemRowContent]).self, returning: [TopicEntity].self) { taskGroup in
            topics.forEach { topic in
                taskGroup.addTask {
                    await getTopicWithImages(topic)
                }
            }
            return await taskGroup.reduce(into: [TopicEntity]()) {
                $0.append(TopicEntity(topic: ItemsWidgetContent(name: $1.0, contentType: .items($1.1))))
            }
        }
    }

    func getTopicWithImages(_ topic: ItemContentContainer) async -> (String, [ItemRowContent]) {
        let contentWithImages = await getContentWithImages(content: topic.items)
        return (topic.name, contentWithImages)
    }

    /// Download thumbnails, attach them to the related item and return the updated list of `[ItemRowContent]`
    /// - Parameter content: the items without thumbnails `[ItemContent]`
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

    /// Downloads the thumbnail for a given `ItemRowContent` item
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

    static let defaultThumbnailResolution = CGSize(width: 320, height: 240)
}
