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
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.PendingItem }
  public static var __selections: [Selection] { [
    .field("url", Url.self),
    .field("status", GraphQLEnum<PendingItemStatus>?.self),
  ] }

  /// URL of the item that the user gave for the SavedItem
  /// that is pending processing by parser
  public var url: Url { __data["url"] }
  public var status: GraphQLEnum<PendingItemStatus>? { __data["status"] }
}
