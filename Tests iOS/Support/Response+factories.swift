// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sails
import SharedPocketKit
import ApolloTestSupport
import Apollo
import PocketGraphTestMocks
import PocketGraph
import NIOCore
import Foundation

extension Response {
    static func saves(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func throttle() -> Response {
        Response {
            Status.tooManyRequests
            Fixture.load(name: "throttled-user").data
        }
    }

    static func internalServerError() -> Response {
        Response {
            Status.internalServerError
            Fixture.load(name: "internal-sever-error-user").data
        }
    }

    static func freeUserSaves(_ fixtureName: String = "initial-list") -> Response {
        saves("initial-list-free-user")
    }

    static func archivedContent() -> Response {
        saves("archived-items")
    }

    static func favoritedArchivedContent() -> Response {
        saves("archived-favorite-items")
    }

    static func slateLineup(_ fixtureName: String = "corpusSlates") -> Response {
        fixture(named: fixtureName)
    }

    static func slateDetail(_ number: Int = 1) -> Response {
        fixture(named: "slate-detail-\(number)")
    }

    static func saveItem(_ fixtureName: String) -> Response {
        fixture(named: fixtureName)
    }

    /// To send a request to save an item
    /// - Parameter apiRequest: apiRequest that is requesting a response
    /// - Returns: returns mock response for `upsertSavedItem`
    static func saveItem(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                upsertSavedItem: Mock<SavedItem>(
                    item: createMockItem(givenUrl: "https://given.example.com/saved-item-1"),
                    url: apiRequest.inputURL.absoluteString
                )
            )
        )
    }

    static func delete(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                savedItemDelete: apiRequest.variableGivenURL
            )
        )
    }

    static func deleteTag(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                deleteTag: apiRequest.variableId
            )
        )
    }

    static func updateTag(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                updateTag: Mock<Tag>(
                    id: apiRequest.inputId,
                    name: apiRequest.inputName
                )
            )
        )
    }

    static func saveTags(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                savedItemTag: Mock<SavedItem>(
                    item: createMockSavedItem(item: createMockItem(givenUrl: apiRequest.givenURL.absoluteString)),
                    url: apiRequest.givenURL.absoluteString
                )
            )
        )
    }

    static func collection(fixtureName: String = "collection-saves") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .data
        }
    }

    /// To send a request to unarchive an item or move from saves, uses same mutation response as `saveItem(apiRequest:)`
    /// - Parameter apiRequest: apiRequest that is requesting a response
    /// - Returns: returns mock response for `upsertSavedItem`
    static func unarchive(apiRequest: ClientAPIRequest) -> Response {
        saveItem(apiRequest: apiRequest)
    }

    static func archive(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                savedItemArchive: Mock<SavedItem>(
                    id: apiRequest.variableGivenURL
                )
            )
        )
    }

    static func favorite(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                savedItemFavorite: Mock<SavedItem>(
                    id: apiRequest.variableGivenURL
                )
            )
        )
    }

    static func unfavorite(apiRequest: ClientAPIRequest) -> Response {
        return .init(
            mock: Mock<Mutation>(
                savedItemUnFavorite: Mock<SavedItem>(
                    id: apiRequest.variableGivenURL
                )
            )
        )
    }

    static func saveItemFromExtension() -> Response {
        fixture(named: "save-item-from-extension")
    }

    static func itemDetail() -> Response {
        return Response {
            Status.ok
            Fixture.load(name: "item-detail")
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func archiveItemDetail() -> Response {
        return Response {
            Status.ok
            Fixture.load(name: "archive-item-detail")
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func recommendationDetail(_ number: Int = 1) -> Response {
        fixture(named: "recommendation-detail-\(number)")
    }

    static func shortUrl() -> Response {
        fixture(named: "shortUrl")
    }

    static func createShareLink() -> Response {
        fixture(named: "createShareLink")
    }

    static func savedItemWithTag() -> Response {
        fixture(named: "list-with-tagged-item")
    }

    static func emptyTags() -> Response {
        return .init(
            mock: Mock<Query>(
                user: Mock<PocketGraphTestMocks.User>(
                    tags: Mock<TagConnection>(
                        edges: [],
                        pageInfo: Mock<PageInfo>(
                            endCursor: nil,
                            hasNextPage: false,
                            hasPreviousPage: false,
                            startCursor: nil
                        ),
                        totalCount: 0
                    )
                )
            )
        )
    }

    static func deleteUser() -> Response {
        return .init(
            mock: Mock<Mutation>(
                deleteUser: "fake-user-id"
            )
        )
    }

    static func deleteUserError() -> Response {
        fixture(named: "deleteUser-error")
    }

    static func premiumStatus() -> Response {
        fixture(named: "premium-status")
    }

    static func userDetails() -> Response {
        return .init(
            mock: Mock<Query>(
                user: Mock<PocketGraphTestMocks.User>(
                    email: "free@mozilla.com",
                    isPremium: false,
                    name: "Pocket User",
                    username: "User Name"
                )
            )
        )
    }

    static func premiumUserDetails() -> Response {
        return .init(
            mock: Mock<Query>(
                user: Mock<PocketGraphTestMocks.User>(
                    email: "premium@mozilla.com",
                    isPremium: true,
                    name: "Pocket User",
                    username: "User Name"
                )
            )
        )
    }

    static func searchList(_ type: SearchScope) -> Response {
        var fixtureName = "search-list"
        switch type {
        case .saves:
            fixtureName = "search-list"
        case .archive:
            fixtureName = "search-list-archive"
        case .all:
            fixtureName = "search-list-all"
        case .premiumSearchByTitle, .premiumSearchByTag, .premiumSearchByContent:
            fixtureName = "search-list-all"
        }

        return Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func searchPagination(_ fixtureName: String = "search-list-page-1") -> Response {
        fixture(named: fixtureName)
    }

    static func featureFlags() -> Response {
        return .init(
            mock: Mock<Query>(
                assignments: Mock<UnleashAssignmentList>(
                    assignments: [
                        Mock<UnleashAssignment>(
                            assigned: true,
                            name: "temp.rick.roll"
                        ),
                        Mock<UnleashAssignment>(
                            assigned: true,
                            name: "perm.feature.on"
                        ),
                        Mock<UnleashAssignment>(
                            assigned: false,
                            name: "temp.feature.off"
                        ),
                        Mock<UnleashAssignment>(
                            assigned: true,
                            name: "temp.feature.variant",
                            variant: "theVariant"
                        ),
                        Mock<UnleashAssignment>(
                            assigned: true,
                            name: "perm.ios.native_collections"
                        )
                    ]
                )
            )
        )
    }

    static func featureFlags(with fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .data
        }
    }

    static func fixture(named fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func fallbackResponses(apiRequest: ClientAPIRequest) -> Response {
        if apiRequest.isForSlateLineup {
            return .slateLineup()
        } else if apiRequest.isForSlateDetail(1) {
            return Response.slateDetail(1)
        } else if apiRequest.isForSlateDetail(2) {
            return Response.slateDetail(2)
        } else if apiRequest.isForArchivedContent {
            return .archivedContent()
        } else if apiRequest.isForTags {
            return .emptyTags()
        } else if apiRequest.isToUpdateTag {
            return .updateTag(apiRequest: apiRequest)
        } else if apiRequest.isForSavesContent {
            return .saves()
        } else if apiRequest.isForDeleteUser {
            return .deleteUser()
        } else if apiRequest.isForUserDetails {
            return .userDetails()
        } else if apiRequest.isToArchiveAnItem {
            return .archive(apiRequest: apiRequest)
        } else if apiRequest.isToSaveAnItem {
            return .saveItem(apiRequest: apiRequest)
        } else if apiRequest.isForRecommendationDetail("slate-1-rec-1") {
            return .recommendationDetail(1)
        } else if apiRequest.isForRecommendationDetail("slate-1-rec-2") {
            return .recommendationDetail(2)
        } else if apiRequest.isForRecommendationDetail("slate-2-rec-1") {
            return .recommendationDetail(3)
        } else if apiRequest.isForRecommendationDetail("slate-2-rec-2") {
            return .recommendationDetail(4)
        } else if apiRequest.isForArchivedItemDetail {
            return .archiveItemDetail()
        } else if apiRequest.isForItemDetail {
            return .itemDetail()
        } else if apiRequest.isForReplacingSavedItemTags {
            return .savedItemWithTag()
        } else if apiRequest.isToFavoriteAnItem {
            return .favorite(apiRequest: apiRequest)
        } else if apiRequest.isToUnfavoriteAnItem {
            return .unfavorite(apiRequest: apiRequest)
        } else if apiRequest.isToDeleteAnItem {
            return .delete(apiRequest: apiRequest)
        } else if apiRequest.isToDeleteATag {
            return .deleteTag(apiRequest: apiRequest)
        } else if apiRequest.isForSearch(.all) {
            return .searchList(.all)
        } else if apiRequest.isForSearch(.saves) {
            return .searchList(.saves)
        } else if apiRequest.isForSearch(.archive) {
            return .searchList(.archive)
        } else if apiRequest.isForFeatureFlags {
            return .featureFlags()
        } else if apiRequest.isForSaveTags {
            return .saveTags(apiRequest: apiRequest)
        } else if apiRequest.isForCollection {
            return .collection()
        } else if apiRequest.isForShortUrl {
            return .shortUrl()
        } else if apiRequest.isForCreateShareLink {
            return .createShareLink()
        } else {
            fatalError("Unexpected request")
        }
    }
}

extension JSONObject: Content {
    public func encode(to buffer: inout ByteBuffer) throws -> Int {
        return try buffer.writeData(JSONSerializationFormat.serialize(value: self))
    }
}

extension Response {
    init(mock: AnyMock) {
        // Wrap the selection data in the general "data" key that the json always has
        var data = JSONObject()
        data.updateValue(mock._selectionSetMockData, forKey: "data")
        self.init(status: .ok, content: data)
    }

    /// Create mock saved item to be used in UI tets
    /// - Returns: `Mock<SavedItem>` with default values
    private static func createMockSavedItem(
        url: String = "http://example.com/item-1",
        id: String? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Int = 0,
        archivedAt: Int? = nil,
        deletedAt: Int? = nil,
        tags: [Mock<Tag>]? = nil,
        item: Mock<Item>
    ) -> Mock<SavedItem> {
        return Mock<SavedItem>(
            _createdAt: createdAt,
            _deletedAt: deletedAt,
            archivedAt: archivedAt,
            id: id,
            isArchived: isArchived,
            isFavorite: isFavorite,
            item: item,
            remoteID: Data(url.utf8).base64EncodedString(),
            tags: tags,
            url: url
        )
    }

    /// Create mock item to be used in UI tests
    /// - Returns: `Mock<Item>` with default values
    private static func createMockItem(
        authors: [Mock<Author>?]? = nil,
        datePublished: PocketGraph.DateString? = "2021-01-01 12:01:01",
        domain: String? = nil,
        excerpt: String? = "Cursus Aenean Elit",
        givenUrl: PocketGraph.Url,
        hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
        hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
        images: [Mock<Image>?]? = nil,
        isArticle: Bool? = true,
        language: String? = "en",
        marticle: [AnyMock]? = createMarticleData(),
        preview: Mock<ItemSummary>? = nil,
        remoteID: String? = nil,
        resolvedUrl: PocketGraph.Url? = nil,
        syndicatedArticle: Mock<SyndicatedArticle>? = nil,
        timeToRead: Int? = Int.random(in: 1..<10),
        title: String? = nil,
        topImageUrl: PocketGraph.Url? = nil,
        wordCount: Int? = Int.random(in: 100..<200)
    ) -> Mock<Item> {
        let authors = [
            Mock<Author>(
                id: "author-1",
                name: "Jacob",
                url: "https://example.com/authors/jacob"
            ),
            Mock<Author>(
                id: "author-2",
                name: "David",
                url: "https://example.com/authors/david"
            )
        ]

        let domainMetadata = Mock<DomainMetadata>(logo: "http://example.com/domain-logo.jpg", name: "WIRED")

        let preview = Mock<ItemSummary>(authors: authors, domain: domainMetadata)

        let images = [
            Mock<Image>(height: 1, imageId: 1, src: "http://example.com/image.jpg", width: 1)
        ]

        return Mock<Item>(
            datePublished: datePublished,
            domain: domain,
            excerpt: excerpt,
            givenUrl: givenUrl,
            hasImage: hasImage,
            hasVideo: hasVideo,
            images: images,
            isArticle: isArticle,
            language: language,
            marticle: marticle,
            preview: preview,
            remoteID: Data(givenUrl.utf8).base64EncodedString(),
            resolvedUrl: resolvedUrl,
            syndicatedArticle: syndicatedArticle,
            timeToRead: timeToRead,
            title: title,
            topImageUrl: topImageUrl,
            wordCount: wordCount
        )
    }

    /// Create marticle data for item
    /// - Returns: returns array of items that make up marticle components
    private static func createMarticleData() -> [AnyMock] {
        [
            Mock<MarticleText>(content: "**Commodo Consectetur** _Dapibus_"),
            Mock<Image>(
                caption: "Nulla vitae elit libero, a pharetra augue. Cras justo odio, dapibus ac facilisis in, egestas eget quam.",
                credit: "Photo by: Bibendum Vestibulum Mollis",
                height: 0,
                imageID: 3,
                src: "https://placekitten.com/2000/1125",
                width: 0
            ),
            Mock<MarticleDivider>(content: "---"),
            Mock<MarticleTable>(html: "<table></table>"),
            Mock<MarticleHeading>(content: "# Purus Vulputate", level: 1),
            Mock<MarticleCodeBlock>(language: 1, text: "<some></some><code></code>"),
//            Mock<Video>(height: 1, length: 2, src: "https://www.youtube.com/watch?v=lEBoIEJxylM", type: GraphQLEnum(.youtube), vid: "lEBoIEJxylM", videoID: 1, width: 2),
            Mock<MarticleBulletedList>(rows: [
                Mock<BulletedListElement>(content: "Pharetra Dapibus Ultricies", level: 0),
                Mock<BulletedListElement>(content: "netus et malesuada", level: 1),
                Mock<BulletedListElement>(content: "quis commodo odio", level: 2),
                Mock<BulletedListElement>(content: "tincidunt ornare massa", level: 3)
            ]),
            Mock<MarticleNumberedList>(rows: [
                Mock<NumberedListElement>(content: "Amet Commodo Fringilla", index: 0, level: 0),
                Mock<NumberedListElement>(content: "nunc sed augue", index: 1, level: 1)
            ]),
            Mock<MarticleBlockquote>(content: "Pellentesque Ridiculus Porta")
        ]
    }
}
