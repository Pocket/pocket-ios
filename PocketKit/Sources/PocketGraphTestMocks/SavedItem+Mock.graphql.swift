// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItem: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SavedItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItem>>

  public struct MockFields {
    @Field<Int>("_createdAt") public var _createdAt
    @Field<Int>("_deletedAt") public var _deletedAt
    @Field<Int>("archivedAt") public var archivedAt
    @Field<CorpusItem>("corpusItem") public var corpusItem
    @Field<PocketGraph.ID>("id") public var id
    @Field<Bool>("isArchived") public var isArchived
    @Field<Bool>("isFavorite") public var isFavorite
    @Field<ItemResult>("item") public var item
    @Field<PocketGraph.ID>("remoteID") public var remoteID
    @Field<[Tag]>("tags") public var tags
    @Field<String>("url") public var url
  }
}

public extension Mock where O == SavedItem {
  convenience init(
    _createdAt: Int? = nil,
    _deletedAt: Int? = nil,
    archivedAt: Int? = nil,
    corpusItem: Mock<CorpusItem>? = nil,
    id: PocketGraph.ID? = nil,
    isArchived: Bool? = nil,
    isFavorite: Bool? = nil,
    item: AnyMock? = nil,
    remoteID: PocketGraph.ID? = nil,
    tags: [Mock<Tag>]? = nil,
    url: String? = nil
  ) {
    self.init()
    _set(_createdAt, for: \._createdAt)
    _set(_deletedAt, for: \._deletedAt)
    _set(archivedAt, for: \.archivedAt)
    _set(corpusItem, for: \.corpusItem)
    _set(id, for: \.id)
    _set(isArchived, for: \.isArchived)
    _set(isFavorite, for: \.isFavorite)
    _set(item, for: \.item)
    _set(remoteID, for: \.remoteID)
    _set(tags, for: \.tags)
    _set(url, for: \.url)
  }
}
