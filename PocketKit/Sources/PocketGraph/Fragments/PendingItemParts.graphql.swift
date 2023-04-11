// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PendingItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PendingItemParts on PendingItem {
      __typename
      url
      status
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PendingItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("url", PocketGraph.Url.self),
    .field("status", GraphQLEnum<PocketGraph.PendingItemStatus>?.self),
  ] }

  public var url: PocketGraph.Url { __data["url"] }
  public var status: GraphQLEnum<PocketGraph.PendingItemStatus>? { __data["status"] }
}
