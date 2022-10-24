// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ItemSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ItemSummary on Item {
      __typename
      remoteID: itemId
      givenUrl
      resolvedUrl
      title
      language
      topImageUrl
      topImageUrl
      timeToRead
      domain
      datePublished
      isArticle
      hasImage
      hasVideo
      authors {
        __typename
        id
        name
        url
      }
      excerpt
      domainMetadata {
        __typename
        ...DomainMetadataParts
      }
      images {
        __typename
        height
        width
        src
        imageId
      }
      syndicatedArticle {
        __typename
        itemId
        mainImage
        title
        excerpt
        publisher {
          __typename
          name
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.Item }
  public static var __selections: [Selection] { [
    .field("itemId", alias: "remoteID", String.self),
    .field("givenUrl", Url.self),
    .field("resolvedUrl", Url?.self),
    .field("title", String?.self),
    .field("language", String?.self),
    .field("topImageUrl", Url?.self),
    .field("timeToRead", Int?.self),
    .field("domain", String?.self),
    .field("datePublished", DateString?.self),
    .field("isArticle", Bool?.self),
    .field("hasImage", GraphQLEnum<Imageness>?.self),
    .field("hasVideo", GraphQLEnum<Videoness>?.self),
    .field("authors", [Author?]?.self),
    .field("excerpt", String?.self),
    .field("domainMetadata", DomainMetadata?.self),
    .field("images", [Image?]?.self),
    .field("syndicatedArticle", SyndicatedArticle?.self),
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
  public var authors: [Author?]? { __data["authors"] }
  /// A snippet of text from the article
  public var excerpt: String? { __data["excerpt"] }
  /// Additional information about the item domain, when present, use this for displaying the domain name
  public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
  /// Array of images within an article
  public var images: [Image?]? { __data["images"] }
  /// If the item has a syndicated counterpart the syndication information
  public var syndicatedArticle: SyndicatedArticle? { __data["syndicatedArticle"] }

  /// Author
  ///
  /// Parent Type: `Author`
  public struct Author: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Author }
    public static var __selections: [Selection] { [
      .field("id", ID.self),
      .field("name", String?.self),
      .field("url", String?.self),
    ] }

    /// Unique id for that Author
    public var id: ID { __data["id"] }
    /// Display name
    public var name: String? { __data["name"] }
    /// A url to that Author's site
    public var url: String? { __data["url"] }
  }

  /// DomainMetadata
  ///
  /// Parent Type: `DomainMetadata`
  public struct DomainMetadata: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.DomainMetadata }
    public static var __selections: [Selection] { [
      .fragment(DomainMetadataParts.self),
    ] }

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

  /// Image
  ///
  /// Parent Type: `Image`
  public struct Image: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Image }
    public static var __selections: [Selection] { [
      .field("height", Int?.self),
      .field("width", Int?.self),
      .field("src", String.self),
      .field("imageId", Int.self),
    ] }

    /// The determined height of the image at the url
    public var height: Int? { __data["height"] }
    /// The determined width of the image at the url
    public var width: Int? { __data["width"] }
    /// Absolute url to the image
    @available(*, deprecated, message: "use url property moving forward")
    public var src: String { __data["src"] }
    /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
    public var imageId: Int { __data["imageId"] }
  }

  /// SyndicatedArticle
  ///
  /// Parent Type: `SyndicatedArticle`
  public struct SyndicatedArticle: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.SyndicatedArticle }
    public static var __selections: [Selection] { [
      .field("itemId", ID?.self),
      .field("mainImage", String?.self),
      .field("title", String.self),
      .field("excerpt", String?.self),
      .field("publisher", Publisher?.self),
    ] }

    /// The item id of this Syndicated Article
    public var itemId: ID? { __data["itemId"] }
    /// Primary image to use in surfacing this content
    public var mainImage: String? { __data["mainImage"] }
    /// Title of syndicated article
    public var title: String { __data["title"] }
    /// Excerpt 
    public var excerpt: String? { __data["excerpt"] }
    /// The manually set publisher information for this article
    public var publisher: Publisher? { __data["publisher"] }

    /// SyndicatedArticle.Publisher
    ///
    /// Parent Type: `Publisher`
    public struct Publisher: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.Publisher }
      public static var __selections: [Selection] { [
        .field("name", String?.self),
      ] }

      /// Name of the publisher of the article
      public var name: String? { __data["name"] }
    }
  }
}
