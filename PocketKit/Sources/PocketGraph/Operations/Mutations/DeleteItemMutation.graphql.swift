// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteItemMutation: GraphQLMutation {
  public static let operationName: String = "DeleteItem"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteItem($givenUrl: Url!, $timestamp: ISOString!) { savedItemDelete(givenUrl: $givenUrl, timestamp: $timestamp) }"#
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
      .field("savedItemDelete", PocketGraph.Url?.self, arguments: [
        "givenUrl": .variable("givenUrl"),
        "timestamp": .variable("timestamp")
      ]),
    ] }

    /// 'Soft-delete' a SavedItem (identified by URL)
    public var savedItemDelete: PocketGraph.Url? { __data["savedItemDelete"] }
  }
}
