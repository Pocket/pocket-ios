// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCollectionBySlugQuery: GraphQLQuery {
  public static let operationName: String = "getCollectionBySlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getCollectionBySlug($slug: String!) { collection: collectionBySlug(slug: $slug) { __typename externalId slug title intro publishedAt authors { __typename name } stories { __typename url title excerpt imageUrl authors { __typename name } publisher item { __typename ...ItemParts } sortOrder } } }"#,
      fragments: [ItemParts.self, MarticleTextParts.self, ImageParts.self, MarticleDividerParts.self, MarticleTableParts.self, MarticleHeadingParts.self, MarticleCodeBlockParts.self, VideoParts.self, MarticleBulletedListParts.self, MarticleNumberedListParts.self, MarticleBlockquoteParts.self, DomainMetadataParts.self, SyndicatedArticleParts.self]
    ))

  public var slug: String

  public init(slug: String) {
    self.slug = slug
  }

  public var __variables: Variables? { ["slug": slug] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("collectionBySlug", alias: "collection", Collection?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Retrieves a Collection by the given slug. The Collection must be published.
    public var collection: Collection? { __data["collection"] }

    /// Collection
    ///
    /// Parent Type: `Collection`
    public struct Collection: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("externalId", PocketGraph.ID.self),
        .field("slug", String.self),
        .field("title", String.self),
        .field("intro", PocketGraph.Markdown?.self),
        .field("publishedAt", PocketGraph.DateString?.self),
        .field("authors", [Author].self),
        .field("stories", [Story].self),
      ] }

      public var externalId: PocketGraph.ID { __data["externalId"] }
      public var slug: String { __data["slug"] }
      public var title: String { __data["title"] }
      public var intro: PocketGraph.Markdown? { __data["intro"] }
      public var publishedAt: PocketGraph.DateString? { __data["publishedAt"] }
      public var authors: [Author] { __data["authors"] }
      public var stories: [Story] { __data["stories"] }

      /// Collection.Author
      ///
      /// Parent Type: `CollectionAuthor`
      public struct Author: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }

      /// Collection.Story
      ///
      /// Parent Type: `CollectionStory`
      public struct Story: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionStory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", PocketGraph.Url.self),
          .field("title", String.self),
          .field("excerpt", PocketGraph.Markdown.self),
          .field("imageUrl", PocketGraph.Url?.self),
          .field("authors", [Author].self),
          .field("publisher", String?.self),
          .field("item", Item?.self),
          .field("sortOrder", Int?.self),
        ] }

        public var url: PocketGraph.Url { __data["url"] }
        public var title: String { __data["title"] }
        public var excerpt: PocketGraph.Markdown { __data["excerpt"] }
        public var imageUrl: PocketGraph.Url? { __data["imageUrl"] }
        public var authors: [Author] { __data["authors"] }
        public var publisher: String? { __data["publisher"] }
        public var item: Item? { __data["item"] }
        public var sortOrder: Int? { __data["sortOrder"] }

        /// Collection.Story.Author
        ///
        /// Parent Type: `CollectionStoryAuthor`
        public struct Author: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionStoryAuthor }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ] }

          public var name: String { __data["name"] }
        }

        /// Collection.Story.Item
        ///
        /// Parent Type: `Item`
        public struct Item: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ItemParts.self),
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
          public var authors: [ItemParts.Author?]? { __data["authors"] }
          /// If the item is a collection allow them to get the collection information
          public var collection: ItemParts.Collection? { __data["collection"] }
          /// The Marticle format of the article, used by clients for native article view.
          public var marticle: [Marticle]? { __data["marticle"] }
          /// A snippet of text from the article
          public var excerpt: String? { __data["excerpt"] }
          /// Additional information about the item domain, when present, use this for displaying the domain name
          public var domainMetadata: DomainMetadata? { __data["domainMetadata"] }
          /// Array of images within an article
          public var images: [ItemParts.Image?]? { __data["images"] }
          /// If the item has a syndicated counterpart the syndication information
          public var syndicatedArticle: SyndicatedArticle? { __data["syndicatedArticle"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var itemParts: ItemParts { _toFragment() }
          }

          /// Collection.Story.Item.Marticle
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

            /// Collection.Story.Item.Marticle.AsMarticleText
            ///
            /// Parent Type: `MarticleText`
            public struct AsMarticleText: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleText }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleTextParts.self,
                ItemParts.Marticle.AsMarticleText.self
              ] }

              /// Markdown text content. Typically, a paragraph.
              public var content: PocketGraph.Markdown { __data["content"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var marticleTextParts: MarticleTextParts { _toFragment() }
              }
            }

            /// Collection.Story.Item.Marticle.AsImage
            ///
            /// Parent Type: `Image`
            public struct AsImage: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Image }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                ImageParts.self,
                ItemParts.Marticle.AsImage.self
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

            /// Collection.Story.Item.Marticle.AsMarticleDivider
            ///
            /// Parent Type: `MarticleDivider`
            public struct AsMarticleDivider: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleDivider }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleDividerParts.self,
                ItemParts.Marticle.AsMarticleDivider.self
              ] }

              /// Always '---'; provided for convenience if building a markdown string
              public var content: PocketGraph.Markdown { __data["content"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var marticleDividerParts: MarticleDividerParts { _toFragment() }
              }
            }

            /// Collection.Story.Item.Marticle.AsMarticleTable
            ///
            /// Parent Type: `MarticleTable`
            public struct AsMarticleTable: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleTable }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleTableParts.self,
                ItemParts.Marticle.AsMarticleTable.self
              ] }

              /// Raw HTML representation of the table.
              public var html: String { __data["html"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var marticleTableParts: MarticleTableParts { _toFragment() }
              }
            }

            /// Collection.Story.Item.Marticle.AsMarticleHeading
            ///
            /// Parent Type: `MarticleHeading`
            public struct AsMarticleHeading: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleHeading }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleHeadingParts.self,
                ItemParts.Marticle.AsMarticleHeading.self
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

            /// Collection.Story.Item.Marticle.AsMarticleCodeBlock
            ///
            /// Parent Type: `MarticleCodeBlock`
            public struct AsMarticleCodeBlock: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleCodeBlock }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleCodeBlockParts.self,
                ItemParts.Marticle.AsMarticleCodeBlock.self
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

            /// Collection.Story.Item.Marticle.AsVideo
            ///
            /// Parent Type: `Video`
            public struct AsVideo: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Video }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                VideoParts.self,
                ItemParts.Marticle.AsVideo.self
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

            /// Collection.Story.Item.Marticle.AsMarticleBulletedList
            ///
            /// Parent Type: `MarticleBulletedList`
            public struct AsMarticleBulletedList: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBulletedList }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleBulletedListParts.self,
                ItemParts.Marticle.AsMarticleBulletedList.self
              ] }

              public var rows: [MarticleBulletedListParts.Row] { __data["rows"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var marticleBulletedListParts: MarticleBulletedListParts { _toFragment() }
              }
            }

            /// Collection.Story.Item.Marticle.AsMarticleNumberedList
            ///
            /// Parent Type: `MarticleNumberedList`
            public struct AsMarticleNumberedList: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleNumberedList }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleNumberedListParts.self,
                ItemParts.Marticle.AsMarticleNumberedList.self
              ] }

              public var rows: [MarticleNumberedListParts.Row] { __data["rows"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var marticleNumberedListParts: MarticleNumberedListParts { _toFragment() }
              }
            }

            /// Collection.Story.Item.Marticle.AsMarticleBlockquote
            ///
            /// Parent Type: `MarticleBlockquote`
            public struct AsMarticleBlockquote: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = GetCollectionBySlugQuery.Data.Collection.Story.Item.Marticle
              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBlockquote }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                MarticleBlockquoteParts.self,
                ItemParts.Marticle.AsMarticleBlockquote.self
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

          /// Collection.Story.Item.DomainMetadata
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

          /// Collection.Story.Item.SyndicatedArticle
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
            public var publisher: SyndicatedArticleParts.Publisher? { __data["publisher"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var syndicatedArticleParts: SyndicatedArticleParts { _toFragment() }
            }
          }
        }
      }
    }
  }
}
