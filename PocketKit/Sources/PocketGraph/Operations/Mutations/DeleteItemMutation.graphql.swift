// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteItemMutation: GraphQLMutation {
  public static let operationName: String = "DeleteItem"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation DeleteItem($itemID: ID!) {
        deleteSavedItem(id: $itemID)
      }
      """
    ))

  public var itemID: ID

  public init(itemID: ID) {
    self.itemID = itemID
  }

  public var __variables: Variables? { ["itemID": itemID] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("deleteSavedItem", ID.self, arguments: ["id": .variable("itemID")]),
    ] }

    /// Deletes a SavedItem from the users list. Returns ID of the
    /// deleted SavedItem
    public var deleteSavedItem: ID { __data["deleteSavedItem"] }
  }
}
