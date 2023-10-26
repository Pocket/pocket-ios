// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SyndicatedArticleParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SyndicatedArticleParts on SyndicatedArticle { __typename itemId mainImage title excerpt publisher { __typename name } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("itemId", PocketGraph.ID?.self),
    .field("mainImage", String?.self),
    .field("title", String.self),
    .field("excerpt", String?.self),
    .field("publisher", Publisher?.self),
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
        ObjectIdentifier(SyndicatedArticleParts.self)
      ]
    ))
  }

  /// Publisher
  ///
  /// Parent Type: `Publisher`
  public struct Publisher: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Publisher }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("name", String?.self),
    ] }

    /// Name of the publisher of the article
    public var name: String? { __data["name"] }

    public init(
      name: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.Publisher.typename,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SyndicatedArticleParts.Publisher.self)
        ]
      ))
    }
  }
}
