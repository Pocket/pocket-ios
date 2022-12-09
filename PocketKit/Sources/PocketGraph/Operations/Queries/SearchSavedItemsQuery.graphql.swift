// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchSavedItemsQuery: GraphQLQuery {
  public static let operationName: String = "SearchSavedItems"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      """
      query SearchSavedItems($term: String!, $pagination: PaginationInput, $filter: SearchFilterInput) {
        user {
          __typename
          searchSavedItems(term: $term, pagination: $pagination, filter: $filter) {
            __typename
            edges {
              __typename
              node {
                __typename
                savedItem {
                  __typename
                  ...SearchSavedItemParts
                }
              }
              cursor
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
              hasPreviousPage
              startCursor
            }
            totalCount
          }
        }
      }
      """,
      fragments: [SearchSavedItemParts.self, TagParts.self, SearchItemParts.self, DomainMetadataParts.self, PendingItemParts.self]
    ))

  public var term: String
  public var pagination: GraphQLNullable<PaginationInput>
  public var filter: GraphQLNullable<SearchFilterInput>

  public init(
    term: String,
    pagination: GraphQLNullable<PaginationInput>,
    filter: GraphQLNullable<SearchFilterInput>
  ) {
    self.term = term
    self.pagination = pagination
    self.filter = filter
  }

  public var __variables: Variables? { [
    "term": term,
    "pagination": pagination,
    "filter": filter
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
        .field("searchSavedItems", SearchSavedItems?.self, arguments: [
          "term": .variable("term"),
          "pagination": .variable("pagination"),
          "filter": .variable("filter")
        ]),
      ] }

      /// Get a paginated list of user items that match a given term
      public var searchSavedItems: SearchSavedItems? { __data["searchSavedItems"] }

      /// User.SearchSavedItems
      ///
      /// Parent Type: `SavedItemSearchResultConnection`
      public struct SearchSavedItems: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { PocketGraph.Objects.SavedItemSearchResultConnection }
        public static var __selections: [Selection] { [
          .field("edges", [Edge].self),
          .field("pageInfo", PageInfo.self),
          .field("totalCount", Int.self),
        ] }

        /// A list of edges.
        public var edges: [Edge] { __data["edges"] }
        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// Identifies the total count of items in the connection.
        public var totalCount: Int { __data["totalCount"] }

        /// User.SearchSavedItems.Edge
        ///
        /// Parent Type: `SavedItemSearchResultEdge`
        public struct Edge: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { PocketGraph.Objects.SavedItemSearchResultEdge }
          public static var __selections: [Selection] { [
            .field("node", Node.self),
            .field("cursor", String.self),
          ] }

          /// The item at the end of the edge.
          public var node: Node { __data["node"] }
          /// A cursor for use in pagination.
          public var cursor: String { __data["cursor"] }

          /// User.SearchSavedItems.Edge.Node
          ///
          /// Parent Type: `SavedItemSearchResult`
          public struct Node: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { PocketGraph.Objects.SavedItemSearchResult }
            public static var __selections: [Selection] { [
              .field("savedItem", SavedItem.self),
            ] }

            public var savedItem: SavedItem { __data["savedItem"] }

            /// User.SearchSavedItems.Edge.Node.SavedItem
            ///
            /// Parent Type: `SavedItem`
            public struct SavedItem: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ParentType { PocketGraph.Objects.SavedItem }
              public static var __selections: [Selection] { [
                .fragment(SearchSavedItemParts.self),
              ] }

              /// The url the user saved to their list
              public var url: String { __data["url"] }
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

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(data: DataDict) { __data = data }

                public var searchSavedItemParts: SearchSavedItemParts { _toFragment() }
              }

              /// User.SearchSavedItems.Edge.Node.SavedItem.Tag
              ///
              /// Parent Type: `Tag`
              public struct Tag: PocketGraph.SelectionSet {
                public let __data: DataDict
                public init(data: DataDict) { __data = data }

                public static var __parentType: ParentType { PocketGraph.Objects.Tag }

                /// The actual tag string the user created for their list
                public var name: String { __data["name"] }
                /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
                public var id: ID { __data["id"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(data: DataDict) { __data = data }

                  public var tagParts: TagParts { _toFragment() }
                }
              }

              /// User.SearchSavedItems.Edge.Node.SavedItem.Item
              ///
              /// Parent Type: `ItemResult`
              public struct Item: PocketGraph.SelectionSet {
                public let __data: DataDict
                public init(data: DataDict) { __data = data }

                public static var __parentType: ParentType { PocketGraph.Unions.ItemResult }

                public var asItem: AsItem? { _asInlineFragment() }
                public var asPendingItem: AsPendingItem? { _asInlineFragment() }

                /// User.SearchSavedItems.Edge.Node.SavedItem.Item.AsItem
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
                  /// The page's / publisher's preferred thumbnail image
                  public var topImage: SearchItemParts.TopImage? { __data["topImage"] }
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
                  public var authors: [SearchItemParts.Author?]? { __data["authors"] }
                  /// Additional information about the item domain, when present, use this for displaying the domain name
                  public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
                  /// Array of images within an article
                  public var images: [SearchItemParts.Image?]? { __data["images"] }
                  /// If the item has a syndicated counterpart the syndication information
                  public var syndicatedArticle: SearchItemParts.SyndicatedArticle? { __data["syndicatedArticle"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(data: DataDict) { __data = data }

                    public var searchItemParts: SearchItemParts { _toFragment() }
                  }

                  /// User.SearchSavedItems.Edge.Node.SavedItem.Item.AsItem.DomainMetadata
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

                /// User.SearchSavedItems.Edge.Node.SavedItem.Item.AsPendingItem
                ///
                /// Parent Type: `PendingItem`
                public struct AsPendingItem: PocketGraph.InlineFragment {
                  public let __data: DataDict
                  public init(data: DataDict) { __data = data }

                  public static var __parentType: ParentType { PocketGraph.Objects.PendingItem }

                  /// URL of the item that the user gave for the SavedItem
                  /// that is pending processing by parser
                  public var url: Url { __data["url"] }
                  public var status: GraphQLEnum<PendingItemStatus>? { __data["status"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(data: DataDict) { __data = data }

                    public var pendingItemParts: PendingItemParts { _toFragment() }
                  }
                }
              }
            }
          }
        }

        /// User.SearchSavedItems.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { PocketGraph.Objects.PageInfo }
          public static var __selections: [Selection] { [
            .field("endCursor", String?.self),
            .field("hasNextPage", Bool.self),
            .field("hasPreviousPage", Bool.self),
            .field("startCursor", String?.self),
          ] }

          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating backwards, are there more items?
          public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
          /// When paginating backwards, the cursor to continue.
          public var startCursor: String? { __data["startCursor"] }
        }
      }
    }
  }
}
