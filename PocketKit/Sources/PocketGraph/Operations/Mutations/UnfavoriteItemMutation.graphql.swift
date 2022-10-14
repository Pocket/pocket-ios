// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class UnfavoriteItemMutation: GraphQLMutation {
  public static let operationName: String = "UnfavoriteItem"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation UnfavoriteItem($itemID: ID!) {
        updateSavedItemUnFavorite(id: $itemID) {
          __typename
          id
        }
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
      .field("updateSavedItemUnFavorite", UpdateSavedItemUnFavorite.self, arguments: ["id": .variable("itemID")]),
    ] }

    /// Unfavorites a SavedItem
    public var updateSavedItemUnFavorite: UpdateSavedItemUnFavorite { __data["updateSavedItemUnFavorite"] }

    /// UpdateSavedItemUnFavorite
    ///
    /// Parent Type: `SavedItem`
    public struct UpdateSavedItemUnFavorite: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.SavedItem }
      public static var __selections: [Selection] { [
        .field("id", ID.self),
      ] }

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var id: ID { __data["id"] }
    }
  }
}
