// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ItemParts on Item {
      __typename
      remoteID: itemId
      givenUrl
      resolvedUrl
      title
      language
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
      marticle {
        __typename
        ...MarticleTextParts
        ...ImageParts
        ...MarticleDividerParts
        ...MarticleTableParts
        ...MarticleHeadingParts
        ...MarticleCodeBlockParts
        ...VideoParts
        ...MarticleBulletedListParts
        ...MarticleNumberedListParts
        ...MarticleBlockquoteParts
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

  /// Marticle
  ///
  /// Parent Type: `MarticleComponent`
  public struct Marticle: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Unions.MarticleComponent }
    public static var __selections: [Selection] { [
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

    /// Marticle.AsMarticleText
    ///
    /// Parent Type: `MarticleText`
    public struct AsMarticleText: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleText }
      public static var __selections: [Selection] { [
        .fragment(MarticleTextParts.self),
      ] }

      /// Markdown text content. Typically, a paragraph.
      public var content: Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleTextParts: MarticleTextParts { _toFragment() }
      }
    }

    /// Marticle.AsImage
    ///
    /// Parent Type: `Image`
    public struct AsImage: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.Image }
      public static var __selections: [Selection] { [
        .fragment(ImageParts.self),
      ] }

      /// A caption or description of the image
      public var caption: String? { __data["caption"] }
      /// A credit for the image, typically who the image belongs to / created by
      public var credit: String? { __data["credit"] }
      /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
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
        public init(data: DataDict) { __data = data }

        public var imageParts: ImageParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleDivider
    ///
    /// Parent Type: `MarticleDivider`
    public struct AsMarticleDivider: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleDivider }
      public static var __selections: [Selection] { [
        .fragment(MarticleDividerParts.self),
      ] }

      /// Always '---'; provided for convenience if building a markdown string
      public var content: Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleDividerParts: MarticleDividerParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleTable
    ///
    /// Parent Type: `MarticleTable`
    public struct AsMarticleTable: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleTable }
      public static var __selections: [Selection] { [
        .fragment(MarticleTableParts.self),
      ] }

      /// Raw HTML representation of the table.
      public var html: String { __data["html"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleTableParts: MarticleTableParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleHeading
    ///
    /// Parent Type: `MarticleHeading`
    public struct AsMarticleHeading: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleHeading }
      public static var __selections: [Selection] { [
        .fragment(MarticleHeadingParts.self),
      ] }

      /// Heading text, in markdown.
      public var content: Markdown { __data["content"] }
      /// Heading level. Restricted to values 1-6.
      public var level: Int { __data["level"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleHeadingParts: MarticleHeadingParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleCodeBlock
    ///
    /// Parent Type: `MarticleCodeBlock`
    public struct AsMarticleCodeBlock: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleCodeBlock }
      public static var __selections: [Selection] { [
        .fragment(MarticleCodeBlockParts.self),
      ] }

      /// Content of a pre tag
      public var text: String { __data["text"] }
      /// Assuming the codeblock was a programming language, this field is used to identify it.
      public var language: Int? { __data["language"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleCodeBlockParts: MarticleCodeBlockParts { _toFragment() }
      }
    }

    /// Marticle.AsVideo
    ///
    /// Parent Type: `Video`
    public struct AsVideo: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.Video }
      public static var __selections: [Selection] { [
        .fragment(VideoParts.self),
      ] }

      /// If known, the height of the video in px
      public var height: Int? { __data["height"] }
      /// Absolute url to the video
      public var src: String { __data["src"] }
      /// The type of video
      public var type: GraphQLEnum<VideoType> { __data["type"] }
      /// The video's id within the service defined by type
      public var vid: String? { __data["vid"] }
      /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
      public var videoID: Int { __data["videoID"] }
      /// If known, the width of the video in px
      public var width: Int? { __data["width"] }
      /// If known, the length of the video in seconds
      public var length: Int? { __data["length"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var videoParts: VideoParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleBulletedList
    ///
    /// Parent Type: `MarticleBulletedList`
    public struct AsMarticleBulletedList: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleBulletedList }
      public static var __selections: [Selection] { [
        .fragment(MarticleBulletedListParts.self),
      ] }

      public var rows: [MarticleBulletedListParts.Row] { __data["rows"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleBulletedListParts: MarticleBulletedListParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleNumberedList
    ///
    /// Parent Type: `MarticleNumberedList`
    public struct AsMarticleNumberedList: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleNumberedList }
      public static var __selections: [Selection] { [
        .fragment(MarticleNumberedListParts.self),
      ] }

      public var rows: [MarticleNumberedListParts.Row] { __data["rows"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleNumberedListParts: MarticleNumberedListParts { _toFragment() }
      }
    }

    /// Marticle.AsMarticleBlockquote
    ///
    /// Parent Type: `MarticleBlockquote`
    public struct AsMarticleBlockquote: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.MarticleBlockquote }
      public static var __selections: [Selection] { [
        .fragment(MarticleBlockquoteParts.self),
      ] }

      /// Markdown text content.
      public var content: Markdown { __data["content"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var marticleBlockquoteParts: MarticleBlockquoteParts { _toFragment() }
      }
    }
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
    ] }

    /// The item id of this Syndicated Article
    public var itemId: ID? { __data["itemId"] }
  }
}
