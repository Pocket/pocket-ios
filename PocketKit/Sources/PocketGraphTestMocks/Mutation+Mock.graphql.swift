// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Mutation: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<Note>("createNoteMarkdown") public var createNoteMarkdown
    @Field<[Highlight]>("createSavedItemHighlights") public var createSavedItemHighlights
    @Field<PocketShare>("createShareLink") public var createShareLink
    @Field<PocketGraph.ID>("deleteNote") public var deleteNote
    @Field<PocketGraph.ID>("deleteSavedItemHighlight") public var deleteSavedItemHighlight
    @Field<PocketGraph.ID>("deleteTag") public var deleteTag
    @Field<PocketGraph.ID>("deleteUser") public var deleteUser
    @Field<Note>("editNoteContentMarkdown") public var editNoteContentMarkdown
    @Field<Note>("editNoteTitle") public var editNoteTitle
    @available(*, deprecated, message: "use saveBatchUpdateTags")
    @Field<[SavedItem]>("replaceSavedItemTags") public var replaceSavedItemTags
    @Field<SavedItem>("savedItemArchive") public var savedItemArchive
    @Field<PocketGraph.Url>("savedItemDelete") public var savedItemDelete
    @Field<SavedItem>("savedItemFavorite") public var savedItemFavorite
    @Field<SavedItem>("savedItemTag") public var savedItemTag
    @Field<SavedItem>("savedItemUnFavorite") public var savedItemUnFavorite
    @available(*, deprecated, message: "use saveBatchUpdateTags")
    @Field<SavedItem>("updateSavedItemRemoveTags") public var updateSavedItemRemoveTags
    @Field<Tag>("updateTag") public var updateTag
    @Field<SavedItem>("upsertSavedItem") public var upsertSavedItem
  }
}

public extension Mock where O == Mutation {
  convenience init(
    createNoteMarkdown: Mock<Note>? = nil,
    createSavedItemHighlights: [Mock<Highlight>]? = nil,
    createShareLink: Mock<PocketShare>? = nil,
    deleteNote: PocketGraph.ID? = nil,
    deleteSavedItemHighlight: PocketGraph.ID? = nil,
    deleteTag: PocketGraph.ID? = nil,
    deleteUser: PocketGraph.ID? = nil,
    editNoteContentMarkdown: Mock<Note>? = nil,
    editNoteTitle: Mock<Note>? = nil,
    replaceSavedItemTags: [Mock<SavedItem>]? = nil,
    savedItemArchive: Mock<SavedItem>? = nil,
    savedItemDelete: PocketGraph.Url? = nil,
    savedItemFavorite: Mock<SavedItem>? = nil,
    savedItemTag: Mock<SavedItem>? = nil,
    savedItemUnFavorite: Mock<SavedItem>? = nil,
    updateSavedItemRemoveTags: Mock<SavedItem>? = nil,
    updateTag: Mock<Tag>? = nil,
    upsertSavedItem: Mock<SavedItem>? = nil
  ) {
    self.init()
    _setEntity(createNoteMarkdown, for: \.createNoteMarkdown)
    _setList(createSavedItemHighlights, for: \.createSavedItemHighlights)
    _setEntity(createShareLink, for: \.createShareLink)
    _setScalar(deleteNote, for: \.deleteNote)
    _setScalar(deleteSavedItemHighlight, for: \.deleteSavedItemHighlight)
    _setScalar(deleteTag, for: \.deleteTag)
    _setScalar(deleteUser, for: \.deleteUser)
    _setEntity(editNoteContentMarkdown, for: \.editNoteContentMarkdown)
    _setEntity(editNoteTitle, for: \.editNoteTitle)
    _setList(replaceSavedItemTags, for: \.replaceSavedItemTags)
    _setEntity(savedItemArchive, for: \.savedItemArchive)
    _setScalar(savedItemDelete, for: \.savedItemDelete)
    _setEntity(savedItemFavorite, for: \.savedItemFavorite)
    _setEntity(savedItemTag, for: \.savedItemTag)
    _setEntity(savedItemUnFavorite, for: \.savedItemUnFavorite)
    _setEntity(updateSavedItemRemoveTags, for: \.updateSavedItemRemoveTags)
    _setEntity(updateTag, for: \.updateTag)
    _setEntity(upsertSavedItem, for: \.upsertSavedItem)
  }
}
