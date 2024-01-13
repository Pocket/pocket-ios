// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchSavesQuery: GraphQLQuery {
  public static let operationName: String = "FetchSaves"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchSaves($pagination: PaginationInput, $savedItemsFilter: SavedItemsFilter) { user { __typename savedItems(pagination: $pagination, filter: $savedItemsFilter) { __typename totalCount pageInfo { __typename hasNextPage endCursor } edges { __typename cursor node { __typename ...SavedItemParts } } } } }"#,
      fragments: [CorpusItemSummary.self, DomainMetadataParts.self, HighlightParts.self, ImageParts.self, ItemParts.self, MarticleBlockquoteParts.self, MarticleBulletedListParts.self, MarticleCodeBlockParts.self, MarticleDividerParts.self, MarticleHeadingParts.self, MarticleNumberedListParts.self, MarticleTableParts.self, MarticleTextParts.self, PendingItemParts.self, SavedItemParts.self, SyndicatedArticleParts.self, TagParts.self, VideoParts.self]
    ))

  public var pagination: GraphQLNullable<PaginationInput>
  public var savedItemsFilter: GraphQLNullable<SavedItemsFilter>

  public init(
    pagination: GraphQLNullable<PaginationInput>,
    savedItemsFilter: GraphQLNullable<SavedItemsFilter>
  ) {
    self.pagination = pagination
    self.savedItemsFilter = savedItemsFilter
  }

  public var __variables: Variables? { [
    "pagination": pagination,
    "savedItemsFilter": savedItemsFilter
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
          "filter": .variable("savedItemsFilter")
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
              .fragment(SavedItemParts.self),
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
            /// Annotations associated to this SavedItem
            public var annotations: Annotations? { __data["annotations"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var savedItemParts: SavedItemParts { _toFragment() }
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

                public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  SavedItemParts.Item.AsItem.self,
                  ItemParts.self
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

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var itemParts: ItemParts { _toFragment() }
                }

                public typealias Author = ItemParts.Author

                public typealias Collection = ItemParts.Collection

                /// User.SavedItems.Edge.Node.Item.AsItem.Marticle
                ///
                /// Parent Type: `MarticleComponent`
                public struct Marticle: PocketGraph.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.MarticleComponent }

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

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleText
                  ///
                  /// Parent Type: `MarticleText`
                  public struct AsMarticleText: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleText }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleText.self,
                      MarticleTextParts.self
                    ] }

                    /// Markdown text content. Typically, a paragraph.
                    public var content: PocketGraph.Markdown { __data["content"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleTextParts: MarticleTextParts { _toFragment() }
                    }
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsImage
                  ///
                  /// Parent Type: `Image`
                  public struct AsImage: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Image }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsImage.self,
                      ImageParts.self
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
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleDivider
                  ///
                  /// Parent Type: `MarticleDivider`
                  public struct AsMarticleDivider: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleDivider }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleDivider.self,
                      MarticleDividerParts.self
                    ] }

                    /// Always '---'; provided for convenience if building a markdown string
                    public var content: PocketGraph.Markdown { __data["content"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleDividerParts: MarticleDividerParts { _toFragment() }
                    }
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleTable
                  ///
                  /// Parent Type: `MarticleTable`
                  public struct AsMarticleTable: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleTable }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleTable.self,
                      MarticleTableParts.self
                    ] }

                    /// Raw HTML representation of the table.
                    public var html: String { __data["html"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleTableParts: MarticleTableParts { _toFragment() }
                    }
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleHeading
                  ///
                  /// Parent Type: `MarticleHeading`
                  public struct AsMarticleHeading: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleHeading }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleHeading.self,
                      MarticleHeadingParts.self
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
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleCodeBlock
                  ///
                  /// Parent Type: `MarticleCodeBlock`
                  public struct AsMarticleCodeBlock: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleCodeBlock }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleCodeBlock.self,
                      MarticleCodeBlockParts.self
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
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsVideo
                  ///
                  /// Parent Type: `Video`
                  public struct AsVideo: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Video }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsVideo.self,
                      VideoParts.self
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
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleBulletedList
                  ///
                  /// Parent Type: `MarticleBulletedList`
                  public struct AsMarticleBulletedList: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBulletedList }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleBulletedList.self,
                      MarticleBulletedListParts.self
                    ] }

                    public var rows: [Row] { __data["rows"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleBulletedListParts: MarticleBulletedListParts { _toFragment() }
                    }

                    public typealias Row = MarticleBulletedListParts.Row
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleNumberedList
                  ///
                  /// Parent Type: `MarticleNumberedList`
                  public struct AsMarticleNumberedList: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleNumberedList }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleNumberedList.self,
                      MarticleNumberedListParts.self
                    ] }

                    public var rows: [Row] { __data["rows"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleNumberedListParts: MarticleNumberedListParts { _toFragment() }
                    }

                    public typealias Row = MarticleNumberedListParts.Row
                  }

                  /// User.SavedItems.Edge.Node.Item.AsItem.Marticle.AsMarticleBlockquote
                  ///
                  /// Parent Type: `MarticleBlockquote`
                  public struct AsMarticleBlockquote: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item.AsItem.Marticle
                    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBlockquote }
                    public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                      ItemParts.Marticle.AsMarticleBlockquote.self,
                      MarticleBlockquoteParts.self
                    ] }

                    /// Markdown text content.
                    public var content: PocketGraph.Markdown { __data["content"] }

                    public struct Fragments: FragmentContainer {
                      public let __data: DataDict
                      public init(_dataDict: DataDict) { __data = _dataDict }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts { _toFragment() }
                    }
                  }
                }

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

                public typealias Image = ItemParts.Image

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

                public typealias RootEntityType = FetchSavesQuery.Data.User.SavedItems.Edge.Node.Item
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PendingItem }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  SavedItemParts.Item.AsPendingItem.self,
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

              /// The name of the online publication that published this story.
              public var publisher: String { __data["publisher"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var corpusItemSummary: CorpusItemSummary { _toFragment() }
              }
            }

            public typealias Annotations = SavedItemParts.Annotations
          }
        }
      }
    }
  }
}
