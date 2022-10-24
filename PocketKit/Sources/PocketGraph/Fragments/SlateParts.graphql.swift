// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SlateParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment SlateParts on Slate {
      __typename
      id
      requestId
      experimentId
      displayName
      description
      recommendations {
        __typename
        id
        item {
          __typename
          ...ItemSummary
        }
        curatedInfo {
          __typename
          ...CuratedInfoParts
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.Slate }
  public static var __selections: [Selection] { [
    .field("id", String.self),
    .field("requestId", ID.self),
    .field("experimentId", ID.self),
    .field("displayName", String?.self),
    .field("description", String?.self),
    .field("recommendations", [Recommendation].self),
  ] }

  public var id: String { __data["id"] }
  /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`. The API will provide a new request id every time apps hit the API.
  public var requestId: ID { __data["requestId"] }
  /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment. Production apps typically won't request a specific one, but can for QA or during a/b testing.
  public var experimentId: ID { __data["experimentId"] }
  /// The name to show to the user for this set of recommendations
  public var displayName: String? { __data["displayName"] }
  /// The description of the the slate
  public var description: String? { __data["description"] }
  /// An ordered list of the recommendations to show to the user
  public var recommendations: [Recommendation] { __data["recommendations"] }

  /// Recommendation
  ///
  /// Parent Type: `Recommendation`
  public struct Recommendation: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Recommendation }
    public static var __selections: [Selection] { [
      .field("id", ID?.self),
      .field("item", Item.self),
      .field("curatedInfo", CuratedInfo?.self),
    ] }

    /// A generated id from the Data and Learning team that represents the Recommendation
    public var id: ID? { __data["id"] }
    /// The Recommendation entity is owned by the Recommendation API service.
    /// We extend it in this service to add an extra field ('curationInfo') to the Recommendation entity.
    /// The key for this entity is the 'itemId' found within the Item entity which is owned by the Parser service.
    public var item: Item { __data["item"] }
    public var curatedInfo: CuratedInfo? { __data["curatedInfo"] }

    /// Recommendation.Item
    ///
    /// Parent Type: `Item`
    public struct Item: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.Item }
      public static var __selections: [Selection] { [
        .fragment(ItemSummary.self),
      ] }

      /// The Item entity is owned by the Parser service.
      /// We only extend it in this service to make this service's schema valid.
      /// The key for this entity is the 'itemId'
      public var remoteID: String { __data["remoteID"] }
      /// key field to identify the Item entity in the Parser service
      public var givenUrl: Url { __data["givenUrl"] }
      /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
      public var resolvedUrl: Url? { __data["resolvedUrl"] }
      /// The title as determined by the parser.
      public var title: String? { __data["title"] }
      /// The detected language of the article
      public var language: String? { __data["language"] }
      /// The page's / publisher's preferred thumbnail image
      @available(*, deprecated, message: "use the topImage object")
      public var topImageUrl: Url? { __data["topImageUrl"] }
      /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
      public var timeToRead: Int? { __data["timeToRead"] }
      /// The domain, such as 'getpocket.com' of the {.resolved_url}
      public var domain: String? { __data["domain"] }
      /// The date the article was published
      public var datePublished: DateString? { __data["datePublished"] }
      /// true if the item is an article
      public var isArticle: Bool? { __data["isArticle"] }
      /// 0=no images, 1=contains images, 2=is an image
      public var hasImage: GraphQLEnum<Imageness>? { __data["hasImage"] }
      /// 0=no videos, 1=contains video, 2=is a video
      public var hasVideo: GraphQLEnum<Videoness>? { __data["hasVideo"] }
      /// List of Authors involved with this article
      public var authors: [ItemSummary.Author?]? { __data["authors"] }
      /// A snippet of text from the article
      public var excerpt: String? { __data["excerpt"] }
      /// Additional information about the item domain, when present, use this for displaying the domain name
      public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
      /// Array of images within an article
      public var images: [ItemSummary.Image?]? { __data["images"] }
      /// If the item has a syndicated counterpart the syndication information
      public var syndicatedArticle: ItemSummary.SyndicatedArticle? { __data["syndicatedArticle"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var itemSummary: ItemSummary { _toFragment() }
      }

      /// Recommendation.Item.DomainMetadata
      ///
      /// Parent Type: `DomainMetadata`
      public struct DomainMetadata: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { PocketGraph.Objects.DomainMetadata }

        /// The name of the domain (e.g., The New York Times)
        public var name: String? { __data["name"] }
        /// Url for the logo image
        public var logo: Url? { __data["logo"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var domainMetadataParts: DomainMetadataParts { _toFragment() }
        }
      }
    }

    /// Recommendation.CuratedInfo
    ///
    /// Parent Type: `CuratedInfo`
    public struct CuratedInfo: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.CuratedInfo }
      public static var __selections: [Selection] { [
        .fragment(CuratedInfoParts.self),
      ] }

      public var excerpt: String? { __data["excerpt"] }
      public var imageSrc: Url? { __data["imageSrc"] }
      public var title: String? { __data["title"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var curatedInfoParts: CuratedInfoParts { _toFragment() }
      }
    }
  }
}
