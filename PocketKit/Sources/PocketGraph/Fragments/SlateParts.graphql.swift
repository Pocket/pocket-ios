// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SlateParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SlateParts on Slate { __typename id requestId experimentId displayName description recommendations { __typename id item { __typename ...CompactItem } curatedInfo { __typename ...CuratedInfoParts } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Slate }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", String.self),
    .field("requestId", PocketGraph.ID.self),
    .field("experimentId", PocketGraph.ID.self),
    .field("displayName", String?.self),
    .field("description", String?.self),
    .field("recommendations", [Recommendation].self),
  ] }

  public var id: String { __data["id"] }
  /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`. The API will provide a new request id every time apps hit the API.
  public var requestId: PocketGraph.ID { __data["requestId"] }
  /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment. Production apps typically won't request a specific one, but can for QA or during a/b testing.
  public var experimentId: PocketGraph.ID { __data["experimentId"] }
  /// The name to show to the user for this set of recommendations
  public var displayName: String? { __data["displayName"] }
  /// The description of the the slate
  public var description: String? { __data["description"] }
  /// An ordered list of the recommendations to show to the user
  public var recommendations: [Recommendation] { __data["recommendations"] }

  public init(
    id: String,
    requestId: PocketGraph.ID,
    experimentId: PocketGraph.ID,
    displayName: String? = nil,
    description: String? = nil,
    recommendations: [Recommendation]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.Slate.typename,
        "id": id,
        "requestId": requestId,
        "experimentId": experimentId,
        "displayName": displayName,
        "description": description,
        "recommendations": recommendations._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(SlateParts.self)
      ]
    ))
  }

  /// Recommendation
  ///
  /// Parent Type: `Recommendation`
  public struct Recommendation: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Recommendation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", PocketGraph.ID.self),
      .field("item", Item.self),
      .field("curatedInfo", CuratedInfo?.self),
    ] }

    /// A generated id from the Data and Learning team that represents the Recommendation
    public var id: PocketGraph.ID { __data["id"] }
    /// The Recommendation entity is owned by the Recommendation API service.
    /// We extend it in this service to add an extra field ('curationInfo') to the Recommendation entity.
    /// The key for this entity is the 'itemId' found within the Item entity which is owned by the Parser service.
    public var item: Item { __data["item"] }
    public var curatedInfo: CuratedInfo? { __data["curatedInfo"] }

    public init(
      id: PocketGraph.ID,
      item: Item,
      curatedInfo: CuratedInfo? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.Recommendation.typename,
          "id": id,
          "item": item._fieldData,
          "curatedInfo": curatedInfo._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SlateParts.Recommendation.self)
        ]
      ))
    }

    /// Recommendation.Item
    ///
    /// Parent Type: `Item`
    public struct Item: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
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
      /// The detected language of the article
      public var language: String? { __data["language"] }
      /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
      public var timeToRead: Int? { __data["timeToRead"] }
      /// true if the item is an article
      public var isArticle: Bool? { __data["isArticle"] }
      /// 0=no images, 1=contains images, 2=is an image
      public var hasImage: GraphQLEnum<PocketGraph.Imageness>? { __data["hasImage"] }
      /// 0=no videos, 1=contains video, 2=is a video
      public var hasVideo: GraphQLEnum<PocketGraph.Videoness>? { __data["hasVideo"] }
      /// Number of words in the article
      public var wordCount: Int? { __data["wordCount"] }
      /// Array of images within an article
      public var images: [Image?]? { __data["images"] }
      /// The client preview/display logic for this url. The requires for each object should be kept in sync with the sub objects requires field.
      public var preview: Preview? { __data["preview"] }
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
        language: String? = nil,
        timeToRead: Int? = nil,
        isArticle: Bool? = nil,
        hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
        hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
        wordCount: Int? = nil,
        images: [Image?]? = nil,
        preview: Preview? = nil,
        syndicatedArticle: SyndicatedArticle? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Item.typename,
            "remoteID": remoteID,
            "givenUrl": givenUrl,
            "resolvedUrl": resolvedUrl,
            "language": language,
            "timeToRead": timeToRead,
            "isArticle": isArticle,
            "hasImage": hasImage,
            "hasVideo": hasVideo,
            "wordCount": wordCount,
            "images": images._fieldData,
            "preview": preview._fieldData,
            "syndicatedArticle": syndicatedArticle._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SlateParts.Recommendation.Item.self),
            ObjectIdentifier(CompactItem.self)
          ]
        ))
      }

      public typealias Image = CompactItem.Image

      public typealias Preview = CompactItem.Preview

      /// Recommendation.Item.SyndicatedArticle
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
              ObjectIdentifier(SlateParts.Recommendation.Item.SyndicatedArticle.self),
              ObjectIdentifier(CompactItem.SyndicatedArticle.self),
              ObjectIdentifier(SyndicatedArticleParts.self)
            ]
          ))
        }

        public typealias Publisher = SyndicatedArticleParts.Publisher
      }
    }

    /// Recommendation.CuratedInfo
    ///
    /// Parent Type: `CuratedInfo`
    public struct CuratedInfo: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CuratedInfo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(CuratedInfoParts.self),
      ] }

      public var excerpt: String? { __data["excerpt"] }
      public var imageSrc: PocketGraph.Url? { __data["imageSrc"] }
      public var title: String? { __data["title"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var curatedInfoParts: CuratedInfoParts { _toFragment() }
      }

      public init(
        excerpt: String? = nil,
        imageSrc: PocketGraph.Url? = nil,
        title: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.CuratedInfo.typename,
            "excerpt": excerpt,
            "imageSrc": imageSrc,
            "title": title,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SlateParts.Recommendation.CuratedInfo.self),
            ObjectIdentifier(CuratedInfoParts.self)
          ]
        ))
      }
    }
  }
}
