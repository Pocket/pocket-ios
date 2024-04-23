// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShareSlugQuery: GraphQLQuery {
  public static let operationName: String = "ShareSlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShareSlug($slug: ID!) { shareSlug(slug: $slug) { __typename ... on PocketShare { slug targetUrl shareUrl preview { __typename id url item { __typename id resolvedUrl givenUrl } } } ... on ShareNotFound { message } } }"#
    ))

  public var slug: ID

  public init(slug: ID) {
    self.slug = slug
  }

  public var __variables: Variables? { ["slug": slug] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("shareSlug", ShareSlug?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Resolve data for a Shared link, or return a Not Found
    /// message if the share does not exist.
    public var shareSlug: ShareSlug? { __data["shareSlug"] }

    /// ShareSlug
    ///
    /// Parent Type: `ShareResult`
    public struct ShareSlug: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.ShareResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsPocketShare.self),
        .inlineFragment(AsShareNotFound.self),
      ] }

      public var asPocketShare: AsPocketShare? { _asInlineFragment() }
      public var asShareNotFound: AsShareNotFound? { _asInlineFragment() }

      /// ShareSlug.AsPocketShare
      ///
      /// Parent Type: `PocketShare`
      public struct AsPocketShare: PocketGraph.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ShareSlugQuery.Data.ShareSlug
        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PocketShare }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("slug", PocketGraph.ID.self),
          .field("targetUrl", PocketGraph.ValidUrl.self),
          .field("shareUrl", PocketGraph.ValidUrl.self),
          .field("preview", Preview?.self),
        ] }

        public var slug: PocketGraph.ID { __data["slug"] }
        public var targetUrl: PocketGraph.ValidUrl { __data["targetUrl"] }
        public var shareUrl: PocketGraph.ValidUrl { __data["shareUrl"] }
        public var preview: Preview? { __data["preview"] }

        /// ShareSlug.AsPocketShare.Preview
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
            .field("item", Item?.self),
          ] }

          public var id: PocketGraph.ID { __data["id"] }
          public var url: PocketGraph.Url { __data["url"] }
          public var item: Item? { __data["item"] }

          /// ShareSlug.AsPocketShare.Preview.Item
          ///
          /// Parent Type: `Item`
          public struct Item: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", PocketGraph.ID.self),
              .field("resolvedUrl", PocketGraph.Url?.self),
              .field("givenUrl", PocketGraph.Url.self),
            ] }

            /// A server generated unique id for this item based on itemId
            public var id: PocketGraph.ID { __data["id"] }
            /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
            public var resolvedUrl: PocketGraph.Url? { __data["resolvedUrl"] }
            /// key field to identify the Item entity in the Parser service
            public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
          }
        }
      }

      /// ShareSlug.AsShareNotFound
      ///
      /// Parent Type: `ShareNotFound`
      public struct AsShareNotFound: PocketGraph.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ShareSlugQuery.Data.ShareSlug
        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.ShareNotFound }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("message", String?.self),
        ] }

        public var message: String? { __data["message"] }
      }
    }
  }
}
