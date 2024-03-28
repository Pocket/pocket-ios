// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCollectionBySlugQuery: GraphQLQuery {
  public static let operationName: String = "getCollectionBySlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCollectionBySlug($slug: String!) { collection: collectionBySlug(slug: $slug) { __typename externalId slug title intro publishedAt authors { __typename name } stories { __typename url title excerpt imageUrl authors { __typename name } publisher item { __typename ...ItemSummary } sortOrder } } }"#,
      fragments: [DomainMetadataParts.self, ItemSummary.self, SyndicatedArticleParts.self]
    ))

  public var slug: String

  public init(slug: String) {
    self.slug = slug
  }

  public var __variables: Variables? { ["slug": slug] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("collectionBySlug", alias: "collection", Collection?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Retrieves a Collection by the given slug. The Collection must be published.
    public var collection: Collection? { __data["collection"] }

    /// Collection
    ///
    /// Parent Type: `Collection`
    public struct Collection: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("externalId", PocketGraph.ID.self),
        .field("slug", String.self),
        .field("title", String.self),
        .field("intro", PocketGraph.Markdown?.self),
        .field("publishedAt", PocketGraph.DateString?.self),
        .field("authors", [Author].self),
        .field("stories", [Story].self),
      ] }

      public var externalId: PocketGraph.ID { __data["externalId"] }
      public var slug: String { __data["slug"] }
      public var title: String { __data["title"] }
      public var intro: PocketGraph.Markdown? { __data["intro"] }
      public var publishedAt: PocketGraph.DateString? { __data["publishedAt"] }
      public var authors: [Author] { __data["authors"] }
      public var stories: [Story] { __data["stories"] }

      /// Collection.Author
      ///
      /// Parent Type: `CollectionAuthor`
      public struct Author: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }

      /// Collection.Story
      ///
      /// Parent Type: `CollectionStory`
      public struct Story: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionStory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", PocketGraph.Url.self),
          .field("title", String.self),
          .field("excerpt", PocketGraph.Markdown.self),
          .field("imageUrl", PocketGraph.Url?.self),
          .field("authors", [Author].self),
          .field("publisher", String?.self),
          .field("item", Item?.self),
          .field("sortOrder", Int?.self),
        ] }

        public var url: PocketGraph.Url { __data["url"] }
        public var title: String { __data["title"] }
        public var excerpt: PocketGraph.Markdown { __data["excerpt"] }
        public var imageUrl: PocketGraph.Url? { __data["imageUrl"] }
        public var authors: [Author] { __data["authors"] }
        public var publisher: String? { __data["publisher"] }
        public var item: Item? { __data["item"] }
        public var sortOrder: Int? { __data["sortOrder"] }

        /// Collection.Story.Author
        ///
        /// Parent Type: `CollectionStoryAuthor`
        public struct Author: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionStoryAuthor }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ] }

          public var name: String { __data["name"] }
        }

        /// Collection.Story.Item
        ///
        /// Parent Type: `Item`
        public struct Item: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ItemSummary.self),
          ] }

          /// The Item entity is owned by the Parser service.
          /// We only extend it in this service to make this service's schema valid.
          /// The key for this entity is the 'itemId'
          public var remoteID: String { __data["remoteID"] }
          /// key field to identify the Item entity in the Parser service
          public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
          /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
          public var resolvedUrl: PocketGraph.Url? { __data["resolvedUrl"] }
          /// Provides short url for the given_url in the format: https://pocket.co/<identifier>.
          /// marked as beta because it's not ready yet for large client request.
          public var shortUrl: PocketGraph.Url? { __data["shortUrl"] }
          /// The title as determined by the parser.
          public var title: String? { __data["title"] }
          /// The detected language of the article
          public var language: String? { __data["language"] }
          /// The page's / publisher's preferred thumbnail image
          @available(*, deprecated, message: "use the topImage object")
          public var topImageUrl: PocketGraph.Url? { __data["topImageUrl"] }
          /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
          public var timeToRead: Int? { __data["timeToRead"] }
          /// The domain, such as 'getpocket.com' of the resolved_url
          public var domain: String? { __data["domain"] }
          /// The date the article was published
          public var datePublished: PocketGraph.DateString? { __data["datePublished"] }
          /// true if the item is an article
          public var isArticle: Bool? { __data["isArticle"] }
          /// 0=no images, 1=contains images, 2=is an image
          public var hasImage: GraphQLEnum<PocketGraph.Imageness>? { __data["hasImage"] }
          /// 0=no videos, 1=contains video, 2=is a video
          public var hasVideo: GraphQLEnum<PocketGraph.Videoness>? { __data["hasVideo"] }
          /// Number of words in the article
          public var wordCount: Int? { __data["wordCount"] }
          /// List of Authors involved with this article
          public var authors: [Author?]? { __data["authors"] }
          /// If the item is a collection allow them to get the collection information
          public var collection: Collection? { __data["collection"] }
          /// A snippet of text from the article
          public var excerpt: String? { __data["excerpt"] }
          /// Additional information about the item domain, when present, use this for displaying the domain name
          public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
          /// Array of images within an article
          public var images: [Image?]? { __data["images"] }
          /// If the item has a syndicated counterpart the syndication information
          public var syndicatedArticle: SyndicatedArticle? { __data["syndicatedArticle"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var itemSummary: ItemSummary { _toFragment() }
          }

          public typealias Author = ItemSummary.Author

          public typealias Collection = ItemSummary.Collection

          /// Collection.Story.Item.DomainMetadata
          ///
          /// Parent Type: `DomainMetadata`
          public struct DomainMetadata: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.DomainMetadata }

            /// The name of the domain (e.g., The New York Times)
            public var name: String? { __data["name"] }
            /// Url for the logo image
            public var logo: PocketGraph.Url? { __data["logo"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var domainMetadataParts: DomainMetadataParts { _toFragment() }
            }
          }

          public typealias Image = ItemSummary.Image

          /// Collection.Story.Item.SyndicatedArticle
          ///
          /// Parent Type: `SyndicatedArticle`
          public struct SyndicatedArticle: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }

            /// The item id of this Syndicated Article
            public var itemId: PocketGraph.ID? { __data["itemId"] }
            /// Primary image to use in surfacing this content
            public var mainImage: String? { __data["mainImage"] }
            /// Title of syndicated article
            public var title: String { __data["title"] }
            /// Excerpt 
            public var excerpt: String? { __data["excerpt"] }
            /// The manually set publisher information for this article
            public var publisher: Publisher? { __data["publisher"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var syndicatedArticleParts: SyndicatedArticleParts { _toFragment() }
            }

            public typealias Publisher = SyndicatedArticleParts.Publisher
          }
        }
      }
    }
  }
}
