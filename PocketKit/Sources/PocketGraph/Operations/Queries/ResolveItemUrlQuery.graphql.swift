// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ResolveItemUrlQuery: GraphQLQuery {
  public static let operationName: String = "ResolveItemUrl"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ResolveItemUrl($url: String!) { itemByUrl(url: $url) { __typename givenUrl } }"#
    ))

  public var url: String

  public init(url: String) {
    self.url = url
  }

  public var __variables: Variables? { ["url": url] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("itemByUrl", ItemByUrl?.self, arguments: ["url": .variable("url")]),
    ] }

    /// Look up Item info by a url.
    public var itemByUrl: ItemByUrl? { __data["itemByUrl"] }

    /// ItemByUrl
    ///
    /// Parent Type: `Item`
    public struct ItemByUrl: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("givenUrl", PocketGraph.Url.self),
      ] }

      /// key field to identify the Item entity in the Parser service
      public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
    }
  }
}
