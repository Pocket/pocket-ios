// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FavoriteItemMutation: GraphQLMutation {
  public static let operationName: String = "FavoriteItem"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation FavoriteItem($givenUrl: Url!, $timestamp: ISOString!) { savedItemFavorite(givenUrl: $givenUrl, timestamp: $timestamp) { __typename id } }"#
    ))

  public var givenUrl: Url
  public var timestamp: ISOString

  public init(
    givenUrl: Url,
    timestamp: ISOString
  ) {
    self.givenUrl = givenUrl
    self.timestamp = timestamp
  }

  public var __variables: Variables? { [
    "givenUrl": givenUrl,
    "timestamp": timestamp
  ] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("savedItemFavorite", SavedItemFavorite?.self, arguments: [
        "givenUrl": .variable("givenUrl"),
        "timestamp": .variable("timestamp")
      ]),
    ] }

    /// Favorite a SavedItem (identified by URL)
    public var savedItemFavorite: SavedItemFavorite? { __data["savedItemFavorite"] }

    /// SavedItemFavorite
    ///
    /// Parent Type: `SavedItem`
    public struct SavedItemFavorite: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItem }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", PocketGraph.ID.self),
      ] }

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var id: PocketGraph.ID { __data["id"] }
    }
  }
}
