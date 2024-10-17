// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusRecommendationParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CorpusRecommendationParts on CorpusRecommendation { __typename id corpusItem { __typename ...CorpusItemParts } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusRecommendation }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", PocketGraph.ID.self),
    .field("corpusItem", CorpusItem.self),
  ] }

  /// Clients should include this id in the `corpus_recommendation` Snowplow entity for impression, content_open, and engagement events related to this recommendation. This id is different across users, across requests, and across corpus items. The recommendation-api service associates metadata with this id to join and aggregate recommendations in our data warehouse.
  public var id: PocketGraph.ID { __data["id"] }
  /// Content meta data.
  public var corpusItem: CorpusItem { __data["corpusItem"] }

  public init(
    id: PocketGraph.ID,
    corpusItem: CorpusItem
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CorpusRecommendation.typename,
        "id": id,
        "corpusItem": corpusItem._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CorpusRecommendationParts.self)
      ]
    ))
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

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var corpusItemParts: CorpusItemParts { _toFragment() }
    }

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
          ObjectIdentifier(CorpusRecommendationParts.CorpusItem.self),
          ObjectIdentifier(CorpusItemParts.self)
        ]
      ))
    }

    public typealias Preview = CorpusItemParts.Preview

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
            ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.self)
          ]
        ))
      }

      /// CorpusItem.Target.AsSyndicatedArticle
      ///
      /// Parent Type: `SyndicatedArticle`
      public struct AsSyndicatedArticle: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = CorpusRecommendationParts.CorpusItem.Target
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
              ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.self),
              ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.AsSyndicatedArticle.self),
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

        public typealias RootEntityType = CorpusRecommendationParts.CorpusItem.Target
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
              ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.self),
              ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.AsCollection.self),
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
                ObjectIdentifier(CorpusRecommendationParts.CorpusItem.Target.AsCollection.Author.self),
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
