// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Note: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Note
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Note>>

  public struct MockFields {
    @Field<Bool>("archived") public var archived
    @Field<PocketGraph.Markdown>("contentPreview") public var contentPreview
    @Field<PocketGraph.ISOString>("createdAt") public var createdAt
    @Field<Bool>("deleted") public var deleted
    @Field<PocketGraph.Markdown>("docMarkdown") public var docMarkdown
    @Field<PocketGraph.ID>("id") public var id
    @Field<SavedItem>("savedItem") public var savedItem
    @Field<PocketGraph.ValidUrl>("source") public var source
    @Field<String>("title") public var title
    @Field<PocketGraph.ISOString>("updatedAt") public var updatedAt
  }
}

public extension Mock where O == Note {
  convenience init(
    archived: Bool? = nil,
    contentPreview: PocketGraph.Markdown? = nil,
    createdAt: PocketGraph.ISOString? = nil,
    deleted: Bool? = nil,
    docMarkdown: PocketGraph.Markdown? = nil,
    id: PocketGraph.ID? = nil,
    savedItem: Mock<SavedItem>? = nil,
    source: PocketGraph.ValidUrl? = nil,
    title: String? = nil,
    updatedAt: PocketGraph.ISOString? = nil
  ) {
    self.init()
    _setScalar(archived, for: \.archived)
    _setScalar(contentPreview, for: \.contentPreview)
    _setScalar(createdAt, for: \.createdAt)
    _setScalar(deleted, for: \.deleted)
    _setScalar(docMarkdown, for: \.docMarkdown)
    _setScalar(id, for: \.id)
    _setEntity(savedItem, for: \.savedItem)
    _setScalar(source, for: \.source)
    _setScalar(title, for: \.title)
    _setScalar(updatedAt, for: \.updatedAt)
  }
}
