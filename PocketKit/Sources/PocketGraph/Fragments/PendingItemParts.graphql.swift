// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PendingItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PendingItemParts on PendingItem { __typename remoteID: itemId givenUrl: url status }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PendingItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("itemId", alias: "remoteID", String.self),
    .field("url", alias: "givenUrl", PocketGraph.Url.self),
    .field("status", GraphQLEnum<PocketGraph.PendingItemStatus>?.self),
  ] }

  /// URL of the item that the user gave for the SavedItem
  /// that is pending processing by parser
  public var remoteID: String { __data["remoteID"] }
  public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
  public var status: GraphQLEnum<PocketGraph.PendingItemStatus>? { __data["status"] }

  public init(
    remoteID: String,
    givenUrl: PocketGraph.Url,
    status: GraphQLEnum<PocketGraph.PendingItemStatus>? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.PendingItem.typename,
        "remoteID": remoteID,
        "givenUrl": givenUrl,
        "status": status,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PendingItemParts.self)
      ]
    ))
  }
}
