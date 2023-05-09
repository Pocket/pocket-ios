// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Mutation: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<PocketGraph.ID>("deleteSavedItem") public var deleteSavedItem
    @Field<PocketGraph.ID>("deleteTag") public var deleteTag
    @Field<PocketGraph.ID>("deleteUser") public var deleteUser
    @available(*, deprecated, message: "use saveBatchUpdateTags")
    @Field<[SavedItem]>("replaceSavedItemTags") public var replaceSavedItemTags
    @Field<SavedItem>("updateSavedItemArchive") public var updateSavedItemArchive
    @Field<SavedItem>("updateSavedItemFavorite") public var updateSavedItemFavorite
    @available(*, deprecated, message: "use saveBatchUpdateTags")
    @Field<SavedItem>("updateSavedItemRemoveTags") public var updateSavedItemRemoveTags
    @Field<SavedItem>("updateSavedItemUnFavorite") public var updateSavedItemUnFavorite
    @Field<Tag>("updateTag") public var updateTag
    @Field<SavedItem>("upsertSavedItem") public var upsertSavedItem
  }
}

public extension Mock where O == Mutation {
  convenience init(
    deleteSavedItem: PocketGraph.ID? = nil,
    deleteTag: PocketGraph.ID? = nil,
    deleteUser: PocketGraph.ID? = nil,
    replaceSavedItemTags: [Mock<SavedItem>]? = nil,
    updateSavedItemArchive: Mock<SavedItem>? = nil,
    updateSavedItemFavorite: Mock<SavedItem>? = nil,
    updateSavedItemRemoveTags: Mock<SavedItem>? = nil,
    updateSavedItemUnFavorite: Mock<SavedItem>? = nil,
    updateTag: Mock<Tag>? = nil,
    upsertSavedItem: Mock<SavedItem>? = nil
  ) {
    self.init()
    self.deleteSavedItem = deleteSavedItem
    self.deleteTag = deleteTag
    self.deleteUser = deleteUser
    self.replaceSavedItemTags = replaceSavedItemTags
    self.updateSavedItemArchive = updateSavedItemArchive
    self.updateSavedItemFavorite = updateSavedItemFavorite
    self.updateSavedItemRemoveTags = updateSavedItemRemoveTags
    self.updateSavedItemUnFavorite = updateSavedItemUnFavorite
    self.updateTag = updateTag
    self.upsertSavedItem = upsertSavedItem
  }
}
