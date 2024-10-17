// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusItemParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CorpusItemParts on CorpusItem { __typename id url timeToRead imageUrl publisher preview { __typename authors { __typename id name url } excerpt title datePublished image { __typename url } domain { __typename ...DomainMetadataParts } } target { __typename ... on SyndicatedArticle { __typename ...SyndicatedArticleParts } ... on Collection { __typename ...CollectionSummary } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", PocketGraph.ID.self),
    .field("url", PocketGraph.Url.self),
    .field("timeToRead", Int?.self),
    .field("imageUrl", PocketGraph.Url.self),
    .field("publisher", String.self),
    .field("preview", Preview.self),
    .field("target", Target?.self),
  ] }

  /// The GUID that is stored on an approved corpus item
  public var id: PocketGraph.ID { __data["id"] }
  /// The URL of the Approved Item.
  public var url: PocketGraph.Url { __data["url"] }
  /// Time to read in minutes. Is nullable.
  public var timeToRead: Int? { __data["timeToRead"] }
  /// The image URL for this item's accompanying picture.
  public var imageUrl: PocketGraph.Url { __data["imageUrl"] }
  /// The name of the online publication that published this story.
  public var publisher: String { __data["publisher"] }
  /// The preview of the search result
  public var preview: Preview { __data["preview"] }
  /// If the Corpus Item is pocket owned with a specific type, this is the associated object (Collection or SyndicatedArticle).
  public var target: Target? { __data["target"] }

  public init(
    id: PocketGraph.ID,
    url: PocketGraph.Url,
    timeToRead: Int? = nil,
    imageUrl: PocketGraph.Url,
    publisher: String,
    preview: Preview,
    target: Target? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CorpusItem.typename,
        "id": id,
        "url": url,
        "timeToRead": timeToRead,
        "imageUrl": imageUrl,
        "publisher": publisher,
        "preview": preview._fieldData,
        "target": target._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CorpusItemParts.self)
      ]
    ))
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
          ObjectIdentifier(CorpusItemParts.Preview.self)
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
            ObjectIdentifier(CorpusItemParts.Preview.Author.self)
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
            ObjectIdentifier(CorpusItemParts.Preview.Image.self)
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
            ObjectIdentifier(CorpusItemParts.Preview.Domain.self),
            ObjectIdentifier(DomainMetadataParts.self)
          ]
        ))
      }
    }
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
