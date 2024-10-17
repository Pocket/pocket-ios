// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CompactItem: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CompactItem on Item { __typename remoteID: itemId givenUrl resolvedUrl language timeToRead isArticle hasImage hasVideo wordCount images { __typename height width src imageId } preview { __typename authors { __typename id name url } excerpt title datePublished image { __typename url } domain { __typename ...DomainMetadataParts } } syndicatedArticle { __typename ...SyndicatedArticleParts } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("itemId", alias: "remoteID", String.self),
    .field("givenUrl", PocketGraph.Url.self),
    .field("resolvedUrl", PocketGraph.Url?.self),
    .field("language", String?.self),
    .field("timeToRead", Int?.self),
    .field("isArticle", Bool?.self),
    .field("hasImage", GraphQLEnum<PocketGraph.Imageness>?.self),
    .field("hasVideo", GraphQLEnum<PocketGraph.Videoness>?.self),
    .field("wordCount", Int?.self),
    .field("images", [Image?]?.self),
    .field("preview", Preview?.self),
    .field("syndicatedArticle", SyndicatedArticle?.self),
  ] }

  /// The Item entity is owned by the Parser service.
  /// We only extend it in this service to make this service's schema valid.
  /// The key for this entity is the 'itemId'
  public var remoteID: String { __data["remoteID"] }
  /// key field to identify the Item entity in the Parser service
  public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
  /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
  public var resolvedUrl: PocketGraph.Url? { __data["resolvedUrl"] }
  /// The detected language of the article
  public var language: String? { __data["language"] }
  /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
  public var timeToRead: Int? { __data["timeToRead"] }
  /// true if the item is an article
  public var isArticle: Bool? { __data["isArticle"] }
  /// 0=no images, 1=contains images, 2=is an image
  public var hasImage: GraphQLEnum<PocketGraph.Imageness>? { __data["hasImage"] }
  /// 0=no videos, 1=contains video, 2=is a video
  public var hasVideo: GraphQLEnum<PocketGraph.Videoness>? { __data["hasVideo"] }
  /// Number of words in the article
  public var wordCount: Int? { __data["wordCount"] }
  /// Array of images within an article
  public var images: [Image?]? { __data["images"] }
  /// The client preview/display logic for this url. The requires for each object should be kept in sync with the sub objects requires field.
  public var preview: Preview? { __data["preview"] }
  /// If the item has a syndicated counterpart the syndication information
  public var syndicatedArticle: SyndicatedArticle? { __data["syndicatedArticle"] }

  public init(
    remoteID: String,
    givenUrl: PocketGraph.Url,
    resolvedUrl: PocketGraph.Url? = nil,
    language: String? = nil,
    timeToRead: Int? = nil,
    isArticle: Bool? = nil,
    hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
    hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
    wordCount: Int? = nil,
    images: [Image?]? = nil,
    preview: Preview? = nil,
    syndicatedArticle: SyndicatedArticle? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.Item.typename,
        "remoteID": remoteID,
        "givenUrl": givenUrl,
        "resolvedUrl": resolvedUrl,
        "language": language,
        "timeToRead": timeToRead,
        "isArticle": isArticle,
        "hasImage": hasImage,
        "hasVideo": hasVideo,
        "wordCount": wordCount,
        "images": images._fieldData,
        "preview": preview._fieldData,
        "syndicatedArticle": syndicatedArticle._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CompactItem.self)
      ]
    ))
  }

  /// Image
  ///
  /// Parent Type: `Image`
  public struct Image: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Image }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
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
    /// The id for placing within an Article View. Item.article will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
    public var imageId: Int { __data["imageId"] }

    public init(
      height: Int? = nil,
      width: Int? = nil,
      src: String,
      imageId: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.Image.typename,
          "height": height,
          "width": width,
          "src": src,
          "imageId": imageId,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CompactItem.Image.self)
        ]
      ))
    }
  }

  /// Preview
  ///
  /// Parent Type: `PocketMetadata`
  public struct Preview: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Interfaces.PocketMetadata }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("authors", [Author]?.self),
      .field("excerpt", String?.self),
      .field("title", String?.self),
      .field("datePublished", PocketGraph.ISOString?.self),
      .field("image", Image?.self),
      .field("domain", Domain?.self),
    ] }

    public var authors: [Author]? { __data["authors"] }
    public var excerpt: String? { __data["excerpt"] }
    public var title: String? { __data["title"] }
    public var datePublished: PocketGraph.ISOString? { __data["datePublished"] }
    public var image: Image? { __data["image"] }
    public var domain: Domain? { __data["domain"] }

    public init(
      __typename: String,
      authors: [Author]? = nil,
      excerpt: String? = nil,
      title: String? = nil,
      datePublished: PocketGraph.ISOString? = nil,
      image: Image? = nil,
      domain: Domain? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
          "authors": authors._fieldData,
          "excerpt": excerpt,
          "title": title,
          "datePublished": datePublished,
          "image": image._fieldData,
          "domain": domain._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CompactItem.Preview.self)
        ]
      ))
    }

    /// Preview.Author
    ///
    /// Parent Type: `Author`
    public struct Author: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Author }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", PocketGraph.ID.self),
        .field("name", String?.self),
        .field("url", String?.self),
      ] }

      /// Unique id for that Author
      public var id: PocketGraph.ID { __data["id"] }
      /// Display name
      public var name: String? { __data["name"] }
      /// A url to that Author's site
      public var url: String? { __data["url"] }

      public init(
        id: PocketGraph.ID,
        name: String? = nil,
        url: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Author.typename,
            "id": id,
            "name": name,
            "url": url,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CompactItem.Preview.Author.self)
          ]
        ))
      }
    }

    /// Preview.Image
    ///
    /// Parent Type: `Image`
    public struct Image: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("url", PocketGraph.Url.self),
      ] }

      /// The url of the image
      public var url: PocketGraph.Url { __data["url"] }

      public init(
        url: PocketGraph.Url
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Image.typename,
            "url": url,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CompactItem.Preview.Image.self)
          ]
        ))
      }
    }

    /// Preview.Domain
    ///
    /// Parent Type: `DomainMetadata`
    public struct Domain: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.DomainMetadata }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(DomainMetadataParts.self),
      ] }

      /// The name of the domain (e.g., The New York Times)
      public var name: String? { __data["name"] }
      /// Url for the logo image
      public var logo: PocketGraph.Url? { __data["logo"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var domainMetadataParts: DomainMetadataParts { _toFragment() }
      }

      public init(
        name: String? = nil,
        logo: PocketGraph.Url? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.DomainMetadata.typename,
            "name": name,
            "logo": logo,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CompactItem.Preview.Domain.self),
            ObjectIdentifier(DomainMetadataParts.self)
          ]
        ))
      }
    }
  }

  /// SyndicatedArticle
  ///
  /// Parent Type: `SyndicatedArticle`
  public struct SyndicatedArticle: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(SyndicatedArticleParts.self),
    ] }

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

    public init(
      itemId: PocketGraph.ID? = nil,
      mainImage: String? = nil,
      title: String,
      excerpt: String? = nil,
      publisher: Publisher? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.SyndicatedArticle.typename,
          "itemId": itemId,
          "mainImage": mainImage,
          "title": title,
          "excerpt": excerpt,
          "publisher": publisher._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CompactItem.SyndicatedArticle.self),
          ObjectIdentifier(SyndicatedArticleParts.self)
        ]
      ))
    }

    public typealias Publisher = SyndicatedArticleParts.Publisher
  }
}
