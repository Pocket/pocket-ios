// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppIntents
import Localization
import WidgetKit
import Sync
import SharedPocketKit
import UIKit
import SwiftUI

@available(iOS 17.0, *)
struct TopicIntent: WidgetConfigurationIntent {
    // TODO: verify the correct way to use LocalizedStringResource with SwiftGen
    static var title = LocalizedStringResource(
        stringLiteral: "Select Topic"
    )
//    static var description = LocalizedStringResource(
//        stringLiteral: "Select a topic to see recommendations."
//    )

    static var description: IntentDescription? = IntentDescription(stringLiteral: "Select a topic to see recommendations.")
    @Parameter(
        title: LocalizedStringResource(
            stringLiteral: "Topic"
        )
    )
    var topicEntity: TopicEntity

    init(topicEntity: TopicEntity) {
        self.topicEntity = topicEntity
    }

    init() {}
}

struct TopicEntity: AppEntity {
    var topic: TopicContent
    var id: String { "\(topic.name)" }
    static var defaultQuery = TopicQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Topic"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(topic.name)")
    }
}

struct TopicQuery: EntityQuery {
    var service: ItemWidgetsService {
        ItemWidgetsService.makeRecommendationsService()!
    }

    func entities(for identifiers: [TopicEntity.ID]) async throws -> [TopicEntity] {
        let itemContainers = service.getTopics(limit: 4).filter { identifiers.contains($0.name) }
        return await getEntriesWithImages(itemContainers)
    }

    func suggestedEntities() async throws -> [TopicEntity] {
        let itemContainers = service.getTopics(limit: 4)
        return await getEntriesWithImages(itemContainers)
    }

    func defaultResult() async -> TopicEntity? {
        try? await suggestedEntities().first ?? TopicEntity(topic: .sampleContent)
    }
}

extension TopicQuery {
    func getEntriesWithImages(_ topics: [ItemContentContainer]) async -> [TopicEntity] {
        return await withTaskGroup(of: (String, [ItemRowContent]).self, returning: [TopicEntity].self) { taskGroup in
            topics.forEach { topic in
                taskGroup.addTask {
                    await getTopicWithImages(topic)
                }
            }
            var index = 0
            return await taskGroup.reduce(into: [TopicEntity]()) {
                $0.append(TopicEntity(topic: TopicContent(name: $1.0, items: $1.1)))
                index += 1
            }
        }
    }

    func getTopicWithImages(_ topic: ItemContentContainer) async -> (String, [ItemRowContent]) {
        let contentWithImages = await getContentWithImages(content: topic.items)
        return (topic.name, contentWithImages)
    }

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

    static let defaultThumbnailResolution = CGSize(width: 320, height: 240)
}
