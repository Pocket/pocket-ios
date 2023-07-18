// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CorpusItemParts on CorpusItem {
      __typename
      id
      url
      title
      excerpt
      imageUrl
      publisher
      target {
        __typename
        ... on SyndicatedArticle {
          __typename
          ...SyndicatedArticleParts
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", PocketGraph.ID.self),
    .field("url", PocketGraph.Url.self),
    .field("title", String.self),
    .field("excerpt", String.self),
    .field("imageUrl", PocketGraph.Url.self),
    .field("publisher", String.self),
    .field("target", Target?.self),
  ] }

  /// The GUID that is stored on an approved corpus item
  public var id: PocketGraph.ID { __data["id"] }
  /// The URL of the Approved Item.
  public var url: PocketGraph.Url { __data["url"] }
  /// The title of the Approved Item.
  public var title: String { __data["title"] }
  /// The excerpt of the Approved Item.
  public var excerpt: String { __data["excerpt"] }
  /// The image URL for this item's accompanying picture.
  public var imageUrl: PocketGraph.Url { __data["imageUrl"] }
  /// The name of the online publication that published this story.
  public var publisher: String { __data["publisher"] }
  /// If the Corpus Item is pocket owned with a specific type, this is the associated object (Collection or SyndicatedArticle).
  public var target: Target? { __data["target"] }

  public init(
    id: PocketGraph.ID,
    url: PocketGraph.Url,
    title: String,
    excerpt: String,
    imageUrl: PocketGraph.Url,
    publisher: String,
    target: Target? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CorpusItem.typename,
        "id": id,
        "url": url,
        "title": title,
        "excerpt": excerpt,
        "imageUrl": imageUrl,
        "publisher": publisher,
        "target": target._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(Self.self)
      ]
    ))
  }

  /// Target
  ///
  /// Parent Type: `CorpusTarget`
  public struct Target: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.CorpusTarget }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsSyndicatedArticle.self),
    ] }

    public var asSyndicatedArticle: AsSyndicatedArticle? { _asInlineFragment() }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(Self.self)
        ]
      ))
    }

    /// Target.AsSyndicatedArticle
    ///
    /// Parent Type: `SyndicatedArticle`
    public struct AsSyndicatedArticle: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = CorpusItemParts.Target
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }
      public static var __selections: [ApolloAPI.Selection] { [
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
      public var publisher: SyndicatedArticleParts.Publisher? { __data["publisher"] }

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
        publisher: SyndicatedArticleParts.Publisher? = nil
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
            ObjectIdentifier(Self.self),
            ObjectIdentifier(CorpusItemParts.Target.self),
            ObjectIdentifier(SyndicatedArticleParts.self)
          ]
        ))
      }
    }
  }
}
