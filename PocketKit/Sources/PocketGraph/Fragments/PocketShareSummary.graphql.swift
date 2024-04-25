// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PocketShareSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PocketShareSummary on PocketShare { __typename slug targetUrl shareUrl preview { __typename id url item { __typename id resolvedUrl givenUrl } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PocketShare }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("slug", PocketGraph.ID.self),
    .field("targetUrl", PocketGraph.ValidUrl.self),
    .field("shareUrl", PocketGraph.ValidUrl.self),
    .field("preview", Preview?.self),
  ] }

  public var slug: PocketGraph.ID { __data["slug"] }
  public var targetUrl: PocketGraph.ValidUrl { __data["targetUrl"] }
  public var shareUrl: PocketGraph.ValidUrl { __data["shareUrl"] }
  public var preview: Preview? { __data["preview"] }

  public init(
    slug: PocketGraph.ID,
    targetUrl: PocketGraph.ValidUrl,
    shareUrl: PocketGraph.ValidUrl,
    preview: Preview? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.PocketShare.typename,
        "slug": slug,
        "targetUrl": targetUrl,
        "shareUrl": shareUrl,
        "preview": preview._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PocketShareSummary.self)
      ]
    ))
  }

  /// Preview
  ///
  /// Parent Type: `ItemSummary`
  public struct Preview: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.ItemSummary }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", PocketGraph.ID.self),
      .field("url", PocketGraph.Url.self),
      .field("item", Item?.self),
    ] }

    public var id: PocketGraph.ID { __data["id"] }
    public var url: PocketGraph.Url { __data["url"] }
    public var item: Item? { __data["item"] }

    public init(
      id: PocketGraph.ID,
      url: PocketGraph.Url,
      item: Item? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.ItemSummary.typename,
          "id": id,
          "url": url,
          "item": item._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PocketShareSummary.Preview.self)
        ]
      ))
    }

    /// Preview.Item
    ///
    /// Parent Type: `Item`
    public struct Item: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", PocketGraph.ID.self),
        .field("resolvedUrl", PocketGraph.Url?.self),
        .field("givenUrl", PocketGraph.Url.self),
      ] }

      /// A server generated unique id for this item based on itemId
      public var id: PocketGraph.ID { __data["id"] }
      /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
      public var resolvedUrl: PocketGraph.Url? { __data["resolvedUrl"] }
      /// key field to identify the Item entity in the Parser service
      public var givenUrl: PocketGraph.Url { __data["givenUrl"] }

      public init(
        id: PocketGraph.ID,
        resolvedUrl: PocketGraph.Url? = nil,
        givenUrl: PocketGraph.Url
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": PocketGraph.Objects.Item.typename,
            "id": id,
            "resolvedUrl": resolvedUrl,
            "givenUrl": givenUrl,
          ],
          fulfilledFragments: [
            ObjectIdentifier(PocketShareSummary.Preview.Item.self)
          ]
        ))
      }
    }
  }
}
