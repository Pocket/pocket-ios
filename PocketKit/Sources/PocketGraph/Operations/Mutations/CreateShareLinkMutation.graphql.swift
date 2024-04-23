// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateShareLinkMutation: GraphQLMutation {
  public static let operationName: String = "CreateShareLink"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateShareLink($target: ValidUrl!) { createShareLink(target: $target) { __typename shareUrl slug targetUrl preview { __typename id url } } }"#
    ))

  public var target: ValidUrl

  public init(target: ValidUrl) {
    self.target = target
  }

  public var __variables: Variables? { ["target": target] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createShareLink", CreateShareLink?.self, arguments: ["target": .variable("target")]),
    ] }

    /// Create a Pocket Share for a provided target URL, optionally
    /// with additional share context.
    public var createShareLink: CreateShareLink? { __data["createShareLink"] }

    /// CreateShareLink
    ///
    /// Parent Type: `PocketShare`
    public struct CreateShareLink: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PocketShare }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("shareUrl", PocketGraph.ValidUrl.self),
        .field("slug", PocketGraph.ID.self),
        .field("targetUrl", PocketGraph.ValidUrl.self),
        .field("preview", Preview?.self),
      ] }

      public var shareUrl: PocketGraph.ValidUrl { __data["shareUrl"] }
      public var slug: PocketGraph.ID { __data["slug"] }
      public var targetUrl: PocketGraph.ValidUrl { __data["targetUrl"] }
      public var preview: Preview? { __data["preview"] }

      /// CreateShareLink.Preview
      ///
      /// Parent Type: `ItemSummary`
      public struct Preview: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.ItemSummary }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PocketGraph.ID.self),
          .field("url", PocketGraph.Url.self),
        ] }

        public var id: PocketGraph.ID { __data["id"] }
        public var url: PocketGraph.Url { __data["url"] }
      }
    }
  }
}
