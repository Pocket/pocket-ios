// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SharedWithYouNeededDataQuery: GraphQLQuery {
  public static let operationName: String = "SharedWithYouNeededData"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query SharedWithYouNeededData($url: String!) {
        itemByUrl(url: $url) {
          __typename
          resolvedItemId: itemId
          givenUrl
          title
          topImageUrl
          timeToRead
          domain
          excerpt
          domainMetadata {
            __typename
            name
          }
        }
      }
      """#
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
        .field("itemId", alias: "resolvedItemId", String.self),
        .field("givenUrl", PocketGraph.Url.self),
        .field("title", String?.self),
        .field("topImageUrl", PocketGraph.Url?.self),
        .field("timeToRead", Int?.self),
        .field("domain", String?.self),
        .field("excerpt", String?.self),
        .field("domainMetadata", DomainMetadata?.self),
      ] }

      /// The Item entity is owned by the Parser service.
      /// We only extend it in this service to make this service's schema valid.
      /// The key for this entity is the 'itemId'
      public var resolvedItemId: String { __data["resolvedItemId"] }
      /// key field to identify the Item entity in the Parser service
      public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
      /// The title as determined by the parser.
      public var title: String? { __data["title"] }
      /// The page's / publisher's preferred thumbnail image
      @available(*, deprecated, message: "use the topImage object")
      public var topImageUrl: PocketGraph.Url? { __data["topImageUrl"] }
      /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
      public var timeToRead: Int? { __data["timeToRead"] }
      /// The domain, such as 'getpocket.com' of the resolved_url
      public var domain: String? { __data["domain"] }
      /// A snippet of text from the article
      public var excerpt: String? { __data["excerpt"] }
      /// Additional information about the item domain, when present, use this for displaying the domain name
      public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }

      /// ItemByUrl.DomainMetadata
      ///
      /// Parent Type: `DomainMetadata`
      public struct DomainMetadata: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.DomainMetadata }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String?.self),
        ] }

        /// The name of the domain (e.g., The New York Times)
        public var name: String? { __data["name"] }
      }
    }
  }
}
