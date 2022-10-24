// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SavedItemSummariesQuery: GraphQLQuery {
  public static let operationName: String = "SavedItemSummaries"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query SavedItemSummaries($pagination: PaginationInput, $filter: SavedItemsFilter, $sort: SavedItemsSort) {
        user {
          __typename
          savedItems(pagination: $pagination, filter: $filter, sort: $sort) {
            __typename
            totalCount
            pageInfo {
              __typename
              hasNextPage
              endCursor
            }
            edges {
              __typename
              cursor
              node {
                __typename
                ...SavedItemSummary
              }
            }
          }
        }
      }
      """,
      fragments: [SavedItemSummary.self, ItemSummary.self, DomainMetadataParts.self]
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
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Query }
    public static var __selections: [Selection] { [
      .field("user", User?.self),
    ] }

    /// Get a user entity for an authenticated client
    public var user: User? { __data["user"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.User }
      public static var __selections: [Selection] { [
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
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { PocketGraph.Objects.SavedItemConnection }
        public static var __selections: [Selection] { [
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
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { PocketGraph.Objects.PageInfo }
          public static var __selections: [Selection] { [
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
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { PocketGraph.Objects.SavedItemEdge }
          public static var __selections: [Selection] { [
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
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { PocketGraph.Objects.SavedItem }
            public static var __selections: [Selection] { [
              .fragment(SavedItemSummary.self),
            ] }

            /// The url the user saved to their list
            public var url: String { __data["url"] }
            /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
            public var remoteID: ID { __data["remoteID"] }
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
            public var tags: [SavedItemSummary.Tag]? { __data["tags"] }
            /// Link to the underlying Pocket Item for the URL
            public var item: Item { __data["item"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public var savedItemSummary: SavedItemSummary { _toFragment() }
            }

            /// User.SavedItems.Edge.Node.Item
            ///
            /// Parent Type: `ItemResult`
            public struct Item: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ParentType { PocketGraph.Unions.ItemResult }

              public var asItem: AsItem? { _asInlineFragment() }

              /// User.SavedItems.Edge.Node.Item.AsItem
              ///
              /// Parent Type: `Item`
              public struct AsItem: PocketGraph.InlineFragment {
                public let __data: DataDict
                public init(data: DataDict) { __data = data }

                public static var __parentType: ParentType { PocketGraph.Objects.Item }

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
                public var authors: [ItemSummary.Author?]? { __data["authors"] }
                /// A snippet of text from the article
                public var excerpt: String? { __data["excerpt"] }
                /// Additional information about the item domain, when present, use this for displaying the domain name
                public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
                /// Array of images within an article
                public var images: [ItemSummary.Image?]? { __data["images"] }
                /// If the item has a syndicated counterpart the syndication information
                public var syndicatedArticle: ItemSummary.SyndicatedArticle? { __data["syndicatedArticle"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(data: DataDict) { __data = data }

                  public var itemSummary: ItemSummary { _toFragment() }
                }

                /// User.SavedItems.Edge.Node.Item.AsItem.DomainMetadata
                ///
                /// Parent Type: `DomainMetadata`
                public struct DomainMetadata: PocketGraph.SelectionSet {
                  public let __data: DataDict
                  public init(data: DataDict) { __data = data }

                  public static var __parentType: ParentType { PocketGraph.Objects.DomainMetadata }

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
              }
            }
          }
        }
      }
    }
  }
}
