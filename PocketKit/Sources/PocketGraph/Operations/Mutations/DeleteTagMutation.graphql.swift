// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteTagMutation: GraphQLMutation {
  public static let operationName: String = "DeleteTag"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation DeleteTag($id: ID!) {
        deleteTag(id: $id)
      }
      """
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("deleteTag", ID.self, arguments: ["id": .variable("id")]),
    ] }

    /// Deletes a Tag object. This is deletes the Tag and all SavedItem associations
    /// (removes the Tag from all SavedItems). Returns ID of the deleted Tag.
    public var deleteTag: ID { __data["deleteTag"] }
  }
}
