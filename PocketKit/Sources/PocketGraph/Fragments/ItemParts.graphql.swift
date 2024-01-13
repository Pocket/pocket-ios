// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ItemParts on Item { __typename remoteID: itemId givenUrl resolvedUrl title language topImageUrl timeToRead domain datePublished isArticle hasImage hasVideo wordCount authors { __typename id name url } collection { __typename slug } marticle { __typename ...MarticleTextParts ...ImageParts ...MarticleDividerParts ...MarticleTableParts ...MarticleHeadingParts ...MarticleCodeBlockParts ...VideoParts ...MarticleBulletedListParts ...MarticleNumberedListParts ...MarticleBlockquoteParts } excerpt domainMetadata { __typename ...DomainMetadataParts } images { __typename height width src imageId } syndicatedArticle { __typename ...SyndicatedArticleParts } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("itemId", alias: "remoteID", String.self),
    .field("givenUrl", PocketGraph.Url.self),
    .field("resolvedUrl", PocketGraph.Url?.self),
    .field("title", String?.self),
    .field("language", String?.self),
    .field("topImageUrl", PocketGraph.Url?.self),
    .field("timeToRead", Int?.self),
    .field("domain", String?.self),
    .field("datePublished", PocketGraph.DateString?.self),
    .field("isArticle", Bool?.self),
    .field("hasImage", GraphQLEnum<PocketGraph.Imageness>?.self),
    .field("hasVideo", GraphQLEnum<PocketGraph.Videoness>?.self),
    .field("wordCount", Int?.self),
    .field("authors", [Author?]?.self),
    .field("collection", Collection?.self),
    .field("marticle", [Marticle]?.self),
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
  public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
  /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
  public var resolvedUrl: PocketGraph.Url? { __data["resolvedUrl"] }
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
  /// The Marticle format of the article, used by clients for native article view.
  public var marticle: [Marticle]? { __data["marticle"] }
  /// A snippet of text from the article
  public var excerpt: String? { __data["excerpt"] }
  /// Additional information about the item domain, when present, use this for displaying the domain name
  public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
  /// Array of images within an article
  public var images: [Image?]? { __data["images"] }
  /// If the item has a syndicated counterpart the syndication information
  public var syndicatedArticle: SyndicatedArticle? { __data["syndicatedArticle"] }

  public init(
    remoteID: String,
    givenUrl: PocketGraph.Url,
    resolvedUrl: PocketGraph.Url? = nil,
    title: String? = nil,
    language: String? = nil,
    topImageUrl: PocketGraph.Url? = nil,
    timeToRead: Int? = nil,
    domain: String? = nil,
    datePublished: PocketGraph.DateString? = nil,
    isArticle: Bool? = nil,
    hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
    hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
    wordCount: Int? = nil,
    authors: [Author?]? = nil,
    collection: Collection? = nil,
    marticle: [Marticle]? = nil,
    excerpt: String? = nil,
    domainMetadata: DomainMetadata? = nil,
    images: [Image?]? = nil,
    syndicatedArticle: SyndicatedArticle? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.Item.typename,
        "remoteID": remoteID,
        "givenUrl": givenUrl,
        "resolvedUrl": resolvedUrl,
        "title": title,
        "language": language,
        "topImageUrl": topImageUrl,
        "timeToRead": timeToRead,
        "domain": domain,
        "datePublished": datePublished,
        "isArticle": isArticle,
        "hasImage": hasImage,
        "hasVideo": hasVideo,
        "wordCount": wordCount,
        "authors": authors._fieldData,
        "collection": collection._fieldData,
        "marticle": marticle._fieldData,
        "excerpt": excerpt,
        "domainMetadata": domainMetadata._fieldData,
        "images": images._fieldData,
        "syndicatedArticle": syndicatedArticle._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ItemParts.self)
      ]
    ))
  }

  /// Author
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
          ObjectIdentifier(ItemParts.Author.self)
        ]
      ))
    }
  }

  /// Collection
  ///
  /// Parent Type: `Collection`
  public struct Collection: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("slug", String.self),
    ] }

    public var slug: String { __data["slug"] }

    public init(
      slug: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.Collection.typename,
          "slug": slug,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ItemParts.Collection.self)
        ]
      ))
    }
  }

  /// Marticle
  ///
  /// Parent Type: `MarticleComponent`
  public struct Marticle: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.MarticleComponent }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsMarticleText.self),
      .inlineFragment(AsImage.self),
      .inlineFragment(AsMarticleDivider.self),
      .inlineFragment(AsMarticleTable.self),
      .inlineFragment(AsMarticleHeading.self),
      .inlineFragment(AsMarticleCodeBlock.self),
      .inlineFragment(AsVideo.self),
      .inlineFragment(AsMarticleBulletedList.self),
      .inlineFragment(AsMarticleNumberedList.self),
      .inlineFragment(AsMarticleBlockquote.self),
    ] }

    public var asMarticleText: AsMarticleText? { _asInlineFragment() }
    public var asImage: AsImage? { _asInlineFragment() }
    public var asMarticleDivider: AsMarticleDivider? { _asInlineFragment() }
    public var asMarticleTable: AsMarticleTable? { _asInlineFragment() }
    public var asMarticleHeading: AsMarticleHeading? { _asInlineFragment() }
    public var asMarticleCodeBlock: AsMarticleCodeBlock? { _asInlineFragment() }
    public var asVideo: AsVideo? { _asInlineFragment() }
    public var asMarticleBulletedList: AsMarticleBulletedList? { _asInlineFragment() }
    public var asMarticleNumberedList: AsMarticleNumberedList? { _asInlineFragment() }
    public var asMarticleBlockquote: AsMarticleBlockquote? { _asInlineFragment() }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ItemParts.Marticle.self)
        ]
      ))
    }

    /// Marticle.AsMarticleText
    ///
    /// Parent Type: `MarticleText`
    public struct AsMarticleText: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleText }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleTextParts.self),
      ] }

      /// Markdown text content. Typically, a paragraph.
      public var content: PocketGraph.Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleTextParts: MarticleTextParts { _toFragment() }
      }

      public init(
        content: PocketGraph.Markdown
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleText.typename,
            "content": content,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleText.self),
            ObjectIdentifier(MarticleTextParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsImage
    ///
    /// Parent Type: `Image`
    public struct AsImage: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(ImageParts.self),
      ] }

      /// A caption or description of the image
      public var caption: String? { __data["caption"] }
      /// A credit for the image, typically who the image belongs to / created by
      public var credit: String? { __data["credit"] }
      /// The id for placing within an Article View. Item.article will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
      public var imageID: Int { __data["imageID"] }
      /// Absolute url to the image
      @available(*, deprecated, message: "use url property moving forward")
      public var src: String { __data["src"] }
      /// The determined height of the image at the url
      public var height: Int? { __data["height"] }
      /// The determined width of the image at the url
      public var width: Int? { __data["width"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var imageParts: ImageParts { _toFragment() }
      }

      public init(
        caption: String? = nil,
        credit: String? = nil,
        imageID: Int,
        src: String,
        height: Int? = nil,
        width: Int? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Image.typename,
            "caption": caption,
            "credit": credit,
            "imageID": imageID,
            "src": src,
            "height": height,
            "width": width,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsImage.self),
            ObjectIdentifier(ImageParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsMarticleDivider
    ///
    /// Parent Type: `MarticleDivider`
    public struct AsMarticleDivider: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleDivider }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleDividerParts.self),
      ] }

      /// Always '---'; provided for convenience if building a markdown string
      public var content: PocketGraph.Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleDividerParts: MarticleDividerParts { _toFragment() }
      }

      public init(
        content: PocketGraph.Markdown
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleDivider.typename,
            "content": content,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleDivider.self),
            ObjectIdentifier(MarticleDividerParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsMarticleTable
    ///
    /// Parent Type: `MarticleTable`
    public struct AsMarticleTable: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleTable }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleTableParts.self),
      ] }

      /// Raw HTML representation of the table.
      public var html: String { __data["html"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleTableParts: MarticleTableParts { _toFragment() }
      }

      public init(
        html: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleTable.typename,
            "html": html,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleTable.self),
            ObjectIdentifier(MarticleTableParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsMarticleHeading
    ///
    /// Parent Type: `MarticleHeading`
    public struct AsMarticleHeading: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleHeading }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleHeadingParts.self),
      ] }

      /// Heading text, in markdown.
      public var content: PocketGraph.Markdown { __data["content"] }
      /// Heading level. Restricted to values 1-6.
      public var level: Int { __data["level"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleHeadingParts: MarticleHeadingParts { _toFragment() }
      }

      public init(
        content: PocketGraph.Markdown,
        level: Int
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleHeading.typename,
            "content": content,
            "level": level,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleHeading.self),
            ObjectIdentifier(MarticleHeadingParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsMarticleCodeBlock
    ///
    /// Parent Type: `MarticleCodeBlock`
    public struct AsMarticleCodeBlock: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleCodeBlock }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleCodeBlockParts.self),
      ] }

      /// Content of a pre tag
      public var text: String { __data["text"] }
      /// Assuming the codeblock was a programming language, this field is used to identify it.
      public var language: Int? { __data["language"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleCodeBlockParts: MarticleCodeBlockParts { _toFragment() }
      }

      public init(
        text: String,
        language: Int? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleCodeBlock.typename,
            "text": text,
            "language": language,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleCodeBlock.self),
            ObjectIdentifier(MarticleCodeBlockParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsVideo
    ///
    /// Parent Type: `Video`
    public struct AsVideo: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Video }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(VideoParts.self),
      ] }

      /// If known, the height of the video in px
      public var height: Int? { __data["height"] }
      /// Absolute url to the video
      public var src: String { __data["src"] }
      /// The type of video
      public var type: GraphQLEnum<PocketGraph.VideoType> { __data["type"] }
      /// The video's id within the service defined by type
      public var vid: String? { __data["vid"] }
      /// The id of the video within Article View. Item.article will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
      public var videoID: Int { __data["videoID"] }
      /// If known, the width of the video in px
      public var width: Int? { __data["width"] }
      /// If known, the length of the video in seconds
      public var length: Int? { __data["length"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var videoParts: VideoParts { _toFragment() }
      }

      public init(
        height: Int? = nil,
        src: String,
        type: GraphQLEnum<PocketGraph.VideoType>,
        vid: String? = nil,
        videoID: Int,
        width: Int? = nil,
        length: Int? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Video.typename,
            "height": height,
            "src": src,
            "type": type,
            "vid": vid,
            "videoID": videoID,
            "width": width,
            "length": length,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsVideo.self),
            ObjectIdentifier(VideoParts.self)
          ]
        ))
      }
    }

    /// Marticle.AsMarticleBulletedList
    ///
    /// Parent Type: `MarticleBulletedList`
    public struct AsMarticleBulletedList: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBulletedList }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleBulletedListParts.self),
      ] }

      public var rows: [Row] { __data["rows"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleBulletedListParts: MarticleBulletedListParts { _toFragment() }
      }

      public init(
        rows: [Row]
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleBulletedList.typename,
            "rows": rows._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleBulletedList.self),
            ObjectIdentifier(MarticleBulletedListParts.self)
          ]
        ))
      }

      public typealias Row = MarticleBulletedListParts.Row
    }

    /// Marticle.AsMarticleNumberedList
    ///
    /// Parent Type: `MarticleNumberedList`
    public struct AsMarticleNumberedList: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleNumberedList }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleNumberedListParts.self),
      ] }

      public var rows: [Row] { __data["rows"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleNumberedListParts: MarticleNumberedListParts { _toFragment() }
      }

      public init(
        rows: [Row]
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleNumberedList.typename,
            "rows": rows._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleNumberedList.self),
            ObjectIdentifier(MarticleNumberedListParts.self)
          ]
        ))
      }

      public typealias Row = MarticleNumberedListParts.Row
    }

    /// Marticle.AsMarticleBlockquote
    ///
    /// Parent Type: `MarticleBlockquote`
    public struct AsMarticleBlockquote: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ItemParts.Marticle
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBlockquote }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(MarticleBlockquoteParts.self),
      ] }

      /// Markdown text content.
      public var content: PocketGraph.Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var marticleBlockquoteParts: MarticleBlockquoteParts { _toFragment() }
      }

      public init(
        content: PocketGraph.Markdown
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.MarticleBlockquote.typename,
            "content": content,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ItemParts.Marticle.self),
            ObjectIdentifier(ItemParts.Marticle.AsMarticleBlockquote.self),
            ObjectIdentifier(MarticleBlockquoteParts.self)
          ]
        ))
      }
    }
  }

  /// DomainMetadata
  ///
  /// Parent Type: `DomainMetadata`
  public struct DomainMetadata: PocketGraph.SelectionSet {
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
          ObjectIdentifier(ItemParts.DomainMetadata.self),
          ObjectIdentifier(DomainMetadataParts.self)
        ]
      ))
    }
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
          ObjectIdentifier(ItemParts.Image.self)
        ]
      ))
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
          ObjectIdentifier(ItemParts.SyndicatedArticle.self),
          ObjectIdentifier(SyndicatedArticleParts.self)
        ]
      ))
    }

    public typealias Publisher = SyndicatedArticleParts.Publisher
  }
}
