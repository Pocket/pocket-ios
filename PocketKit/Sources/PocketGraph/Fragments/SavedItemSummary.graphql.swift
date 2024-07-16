// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SavedItemSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SavedItemSummary on SavedItem { __typename url remoteID: id isArchived isFavorite _deletedAt _createdAt archivedAt tags { __typename ...TagParts } item { __typename ...CompactItem ...PendingItemParts } corpusItem { __typename ...CorpusItemParts } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("url", String.self),
    .field("id", alias: "remoteID", PocketGraph.ID.self),
    .field("isArchived", Bool.self),
    .field("isFavorite", Bool.self),
    .field("_deletedAt", Int?.self),
    .field("_createdAt", Int.self),
    .field("archivedAt", Int?.self),
    .field("tags", [Tag]?.self),
    .field("item", Item.self),
    .field("corpusItem", CorpusItem?.self),
  ] }

  /// The url the user saved to their list
  public var url: String { __data["url"] }
  /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
  public var remoteID: PocketGraph.ID { __data["remoteID"] }
  /// Helper property to indicate if the SavedItem is archived
  public var isArchived: Bool { __data["isArchived"] }
  /// Helper property to indicate if the SavedItem is favorited
  public var isFavorite: Bool { __data["isFavorite"] }
  /// Unix timestamp of when the entity was deleted, 30 days after this date this entity will be HARD deleted from the database and no longer exist
  public var _deletedAt: Int? { __data["_deletedAt"] }
  /// Unix timestamp of when the entity was created
  public var _createdAt: Int { __data["_createdAt"] }
  /// Timestamp that the SavedItem became archied, null if not archived
  public var archivedAt: Int? { __data["archivedAt"] }
  /// The Tags associated with this SavedItem
  public var tags: [Tag]? { __data["tags"] }
  /// Link to the underlying Pocket Item for the URL
  public var item: Item { __data["item"] }
  /// If the item is in corpus allow the saved item to reference it.  Exposing curated info for consistent UX
  public var corpusItem: CorpusItem? { __data["corpusItem"] }

  public init(
    url: String,
    remoteID: PocketGraph.ID,
    isArchived: Bool,
    isFavorite: Bool,
    _deletedAt: Int? = nil,
    _createdAt: Int,
    archivedAt: Int? = nil,
    tags: [Tag]? = nil,
    item: Item,
    corpusItem: CorpusItem? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.SavedItem.typename,
        "url": url,
        "remoteID": remoteID,
        "isArchived": isArchived,
        "isFavorite": isFavorite,
        "_deletedAt": _deletedAt,
        "_createdAt": _createdAt,
        "archivedAt": archivedAt,
        "tags": tags._fieldData,
        "item": item._fieldData,
        "corpusItem": corpusItem._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(SavedItemSummary.self)
      ]
    ))
  }

  /// Tag
  ///
  /// Parent Type: `Tag`
  public struct Tag: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Tag }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(TagParts.self),
    ] }

    /// The actual tag string the user created for their list
    public var name: String { __data["name"] }
    /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
    public var id: PocketGraph.ID { __data["id"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var tagParts: TagParts { _toFragment() }
    }

    public init(
      name: String,
      id: PocketGraph.ID
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.Tag.typename,
          "name": name,
          "id": id,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SavedItemSummary.Tag.self),
          ObjectIdentifier(TagParts.self)
        ]
      ))
    }
  }

  /// Item
  ///
  /// Parent Type: `ItemResult`
  public struct Item: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.ItemResult }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsItem.self),
      .inlineFragment(AsPendingItem.self),
    ] }

    public var asItem: AsItem? { _asInlineFragment() }
    public var asPendingItem: AsPendingItem? { _asInlineFragment() }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SavedItemSummary.Item.self)
        ]
      ))
    }

    /// Item.AsItem
    ///
    /// Parent Type: `Item`
    public struct AsItem: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = SavedItemSummary.Item
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(CompactItem.self),
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

        public var compactItem: CompactItem { _toFragment() }
      }

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
            "excerpt": excerpt,
            "domainMetadata": domainMetadata._fieldData,
            "images": images._fieldData,
            "syndicatedArticle": syndicatedArticle._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SavedItemSummary.Item.self),
            ObjectIdentifier(SavedItemSummary.Item.AsItem.self),
            ObjectIdentifier(CompactItem.self)
          ]
        ))
      }

      public typealias Author = CompactItem.Author

      /// Item.AsItem.DomainMetadata
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
              ObjectIdentifier(SavedItemSummary.Item.AsItem.DomainMetadata.self),
              ObjectIdentifier(CompactItem.DomainMetadata.self),
              ObjectIdentifier(DomainMetadataParts.self)
            ]
          ))
        }
      }

      public typealias Image = CompactItem.Image

      /// Item.AsItem.SyndicatedArticle
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
              ObjectIdentifier(SavedItemSummary.Item.AsItem.SyndicatedArticle.self),
              ObjectIdentifier(CompactItem.SyndicatedArticle.self),
              ObjectIdentifier(SyndicatedArticleParts.self)
            ]
          ))
        }

        public typealias Publisher = SyndicatedArticleParts.Publisher
      }
    }

    /// Item.AsPendingItem
    ///
    /// Parent Type: `PendingItem`
    public struct AsPendingItem: PocketGraph.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = SavedItemSummary.Item
      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PendingItem }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(PendingItemParts.self),
      ] }

      /// URL of the item that the user gave for the SavedItem
      /// that is pending processing by parser
      public var remoteID: String { __data["remoteID"] }
      public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
      public var status: GraphQLEnum<PocketGraph.PendingItemStatus>? { __data["status"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var pendingItemParts: PendingItemParts { _toFragment() }
      }

      public init(
        remoteID: String,
        givenUrl: PocketGraph.Url,
        status: GraphQLEnum<PocketGraph.PendingItemStatus>? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.PendingItem.typename,
            "remoteID": remoteID,
            "givenUrl": givenUrl,
            "status": status,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SavedItemSummary.Item.self),
            ObjectIdentifier(SavedItemSummary.Item.AsPendingItem.self),
            ObjectIdentifier(PendingItemParts.self)
          ]
        ))
      }
    }
  }

  /// CorpusItem
  ///
  /// Parent Type: `CorpusItem`
  public struct CorpusItem: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(CorpusItemParts.self),
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

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var corpusItemParts: CorpusItemParts { _toFragment() }
    }

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
          ObjectIdentifier(SavedItemSummary.CorpusItem.self),
          ObjectIdentifier(CorpusItemParts.self)
        ]
      ))
    }

    /// CorpusItem.Target
    ///
    /// Parent Type: `CorpusTarget`
    public struct Target: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.CorpusTarget }

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
            ObjectIdentifier(SavedItemSummary.CorpusItem.Target.self)
          ]
        ))
      }

      /// CorpusItem.Target.AsSyndicatedArticle
      ///
      /// Parent Type: `SyndicatedArticle`
      public struct AsSyndicatedArticle: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SavedItemSummary.CorpusItem.Target
        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          CorpusItemParts.Target.AsSyndicatedArticle.self,
          SyndicatedArticleParts.self
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
              ObjectIdentifier(SavedItemSummary.CorpusItem.Target.self),
              ObjectIdentifier(SavedItemSummary.CorpusItem.Target.AsSyndicatedArticle.self),
              ObjectIdentifier(CorpusItemParts.Target.self),
              ObjectIdentifier(CorpusItemParts.Target.AsSyndicatedArticle.self),
              ObjectIdentifier(SyndicatedArticleParts.self)
            ]
          ))
        }

        public typealias Publisher = SyndicatedArticleParts.Publisher
      }

      /// CorpusItem.Target.AsCollection
      ///
      /// Parent Type: `Collection`
      public struct AsCollection: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SavedItemSummary.CorpusItem.Target
        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          CorpusItemParts.Target.AsCollection.self,
          CollectionSummary.self
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
              ObjectIdentifier(SavedItemSummary.CorpusItem.Target.self),
              ObjectIdentifier(SavedItemSummary.CorpusItem.Target.AsCollection.self),
              ObjectIdentifier(CorpusItemParts.Target.self),
              ObjectIdentifier(CorpusItemParts.Target.AsCollection.self),
              ObjectIdentifier(CollectionSummary.self)
            ]
          ))
        }

        /// CorpusItem.Target.AsCollection.Author
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
                ObjectIdentifier(SavedItemSummary.CorpusItem.Target.AsCollection.Author.self),
                ObjectIdentifier(CollectionSummary.Author.self),
                ObjectIdentifier(CollectionAuthorSummary.self)
              ]
            ))
          }
        }
      }
    }
  }
}
