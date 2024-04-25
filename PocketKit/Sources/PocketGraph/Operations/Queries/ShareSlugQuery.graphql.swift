// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShareSlugQuery: GraphQLQuery {
  public static let operationName: String = "ShareSlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShareSlug($slug: ID!) { shareSlug(slug: $slug) { __typename ...PocketShareSummary ... on ShareNotFound { message } } }"#,
      fragments: [PocketShareSummary.self]
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
          .fragment(PocketShareSummary.self),
        ] }

        public var slug: PocketGraph.ID { __data["slug"] }
        public var targetUrl: PocketGraph.ValidUrl { __data["targetUrl"] }
        public var shareUrl: PocketGraph.ValidUrl { __data["shareUrl"] }
        public var preview: Preview? { __data["preview"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var pocketShareSummary: PocketShareSummary { _toFragment() }
        }

        public typealias Preview = PocketShareSummary.Preview
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
