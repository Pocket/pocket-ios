// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchArchiveQuery: GraphQLQuery {
  public static let operationName: String = "FetchArchive"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchArchive($pagination: PaginationInput, $filter: SavedItemsFilter, $sort: SavedItemsSort) { user { __typename savedItems(pagination: $pagination, filter: $filter, sort: $sort) { __typename totalCount pageInfo { __typename hasNextPage endCursor } edges { __typename cursor node { __typename ...SavedItemSummary } } } } }"#,
      fragments: [CollectionAuthorSummary.self, CollectionSummary.self, CompactItem.self, CorpusItemParts.self, DomainMetadataParts.self, PendingItemParts.self, SavedItemSummary.self, SyndicatedArticleParts.self, TagParts.self]
    ))

  public var pagination: GraphQLNullable<PaginationInput>
  public var filter: GraphQLNullable<SavedItemsFilter>
  public var sort: GraphQLNullable<SavedItemsSort>

  public init(
    pagination: GraphQLNullable<PaginationInput>,
    filter: GraphQLNullable<SavedItemsFilter>,
    sort: GraphQLNullable<SavedItemsSort>
  ) {
    self.pagination = pagination
    self.filter = filter
    self.sort = sort
  }

  public var __variables: Variables? { [
    "pagination": pagination,
    "filter": filter,
    "sort": sort
  ] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("user", User?.self),
    ] }

    /// Get a user entity for an authenticated client
    public var user: User? { __data["user"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("savedItems", SavedItems?.self, arguments: [
          "pagination": .variable("pagination"),
          "filter": .variable("filter"),
          "sort": .variable("sort")
        ]),
      ] }

      /// Get a general paginated listing of all SavedItems for the user
      public var savedItems: SavedItems? { __data["savedItems"] }

      /// User.SavedItems
      ///
      /// Parent Type: `SavedItemConnection`
      public struct SavedItems: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItemConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalCount", Int.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge?]?.self),
        ] }

        /// Identifies the total count of SavedItems in the connection.
        public var totalCount: Int { __data["totalCount"] }
        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of edges.
        public var edges: [Edge?]? { __data["edges"] }

        /// User.SavedItems.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// User.SavedItems.Edge
        ///
        /// Parent Type: `SavedItemEdge`
        public struct Edge: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItemEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node?.self),
          ] }

          /// A cursor for use in pagination.
          public var cursor: String { __data["cursor"] }
          /// The SavedItem at the end of the edge.
          public var node: Node? { __data["node"] }

          /// User.SavedItems.Edge.Node
          ///
          /// Parent Type: `SavedItem`
          public struct Node: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItem }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(SavedItemSummary.self),
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

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var savedItemSummary: SavedItemSummary { _toFragment() }
            }

            /// User.SavedItems.Edge.Node.Tag
            ///
            /// Parent Type: `Tag`
            public struct Tag: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Tag }

              /// The actual tag string the user created for their list
              public var name: String { __data["name"] }
              /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
              public var id: PocketGraph.ID { __data["id"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var tagParts: TagParts { _toFragment() }
              }
            }

            /// User.SavedItems.Edge.Node.Item
            ///
            /// Parent Type: `ItemResult`
            public struct Item: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.ItemResult }

              public var asItem: AsItem? { _asInlineFragment() }
              public var asPendingItem: AsPendingItem? { _asInlineFragment() }

              /// User.SavedItems.Edge.Node.Item.AsItem
              ///
              /// Parent Type: `Item`
              public struct AsItem: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = FetchArchiveQuery.Data.User.SavedItems.Edge.Node.Item
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  SavedItemSummary.Item.AsItem.self,
                  CompactItem.self
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

                public typealias Author = CompactItem.Author

                /// User.SavedItems.Edge.Node.Item.AsItem.DomainMetadata
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
                }

                public typealias Image = CompactItem.Image

                /// User.SavedItems.Edge.Node.Item.AsItem.SyndicatedArticle
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

                  public typealias Publisher = SyndicatedArticleParts.Publisher
                }
              }

              /// User.SavedItems.Edge.Node.Item.AsPendingItem
              ///
              /// Parent Type: `PendingItem`
              public struct AsPendingItem: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = FetchArchiveQuery.Data.User.SavedItems.Edge.Node.Item
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PendingItem }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  SavedItemSummary.Item.AsPendingItem.self,
                  PendingItemParts.self
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
              }
            }

            /// User.SavedItems.Edge.Node.CorpusItem
            ///
            /// Parent Type: `CorpusItem`
            public struct CorpusItem: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }

              /// The GUID that is stored on an approved corpus item
              public var id: PocketGraph.ID { __data["id"] }
              /// The URL of the Approved Item.
              public var url: PocketGraph.Url { __data["url"] }
              /// The title of the Approved Item.
              public var title: String { __data["title"] }
              /// Time to read in minutes. Is nullable.
              public var timeToRead: Int? { __data["timeToRead"] }
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

              /// User.SavedItems.Edge.Node.CorpusItem.Target
              ///
              /// Parent Type: `CorpusTarget`
              public struct Target: PocketGraph.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.CorpusTarget }

                public var asSyndicatedArticle: AsSyndicatedArticle? { _asInlineFragment() }
                public var asCollection: AsCollection? { _asInlineFragment() }

                /// User.SavedItems.Edge.Node.CorpusItem.Target.AsSyndicatedArticle
                ///
                /// Parent Type: `SyndicatedArticle`
                public struct AsSyndicatedArticle: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public typealias RootEntityType = FetchArchiveQuery.Data.User.SavedItems.Edge.Node.CorpusItem.Target
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

                  public typealias Publisher = SyndicatedArticleParts.Publisher
                }

                /// User.SavedItems.Edge.Node.CorpusItem.Target.AsCollection
                ///
                /// Parent Type: `Collection`
                public struct AsCollection: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public typealias RootEntityType = FetchArchiveQuery.Data.User.SavedItems.Edge.Node.CorpusItem.Target
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

                  /// User.SavedItems.Edge.Node.CorpusItem.Target.AsCollection.Author
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
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
