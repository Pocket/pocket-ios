// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CorpusItemParts on CorpusItem { __typename id url title excerpt imageUrl shortUrl publisher target { __typename ... on SyndicatedArticle { __typename ...SyndicatedArticleParts } ... on Collection { __typename ...CollectionSummary } } }"#
  }

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
    .field("shortUrl", PocketGraph.Url?.self),
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
  /// Provides short url for the given_url in the format: https://pocket.co/<identifier>.
  /// marked as beta because it's not ready yet for large client request.
  public var shortUrl: PocketGraph.Url? { __data["shortUrl"] }
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
    shortUrl: PocketGraph.Url? = nil,
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
        "shortUrl": shortUrl,
        "publisher": publisher,
        "target": target._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CorpusItemParts.self)
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
      .inlineFragment(AsCollection.self),
    ] }

    public var asSyndicatedArticle: AsSyndicatedArticle? { _asInlineFragment() }
    public var asCollection: AsCollection? { _asInlineFragment() }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CorpusItemParts.Target.self)
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
            ObjectIdentifier(CorpusItemParts.Target.self),
            ObjectIdentifier(CorpusItemParts.Target.AsSyndicatedArticle.self),
            ObjectIdentifier(SyndicatedArticleParts.self)
          ]
        ))
      }

      public typealias Publisher = SyndicatedArticleParts.Publisher
    }

    /// Target.AsCollection
    ///
    /// Parent Type: `Collection`
    public struct AsCollection: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = CorpusItemParts.Target
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(CollectionSummary.self),
      ] }

      public var slug: String { __data["slug"] }
      public var authors: [Author] { __data["authors"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var collectionSummary: CollectionSummary { _toFragment() }
      }

      public init(
        slug: String,
        authors: [Author]
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Collection.typename,
            "slug": slug,
            "authors": authors._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CorpusItemParts.Target.self),
            ObjectIdentifier(CorpusItemParts.Target.AsCollection.self),
            ObjectIdentifier(CollectionSummary.self)
          ]
        ))
      }

      /// Target.AsCollection.Author
      ///
      /// Parent Type: `CollectionAuthor`
      public struct Author: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }

        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var collectionAuthorSummary: CollectionAuthorSummary { _toFragment() }
        }

        public init(
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": PocketGraph.Objects.CollectionAuthor.typename,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(CorpusItemParts.Target.AsCollection.Author.self),
              ObjectIdentifier(CollectionSummary.Author.self),
              ObjectIdentifier(CollectionAuthorSummary.self)
            ]
          ))
        }
      }
    }
  }
}
