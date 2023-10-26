// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CollectionSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CollectionSummary on Collection { __typename slug authors { __typename ...CollectionAuthorSummary } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("slug", String.self),
    .field("authors", [Author].self),
  ] }

  public var slug: String { __data["slug"] }
  public var authors: [Author] { __data["authors"] }

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
        ObjectIdentifier(CollectionSummary.self)
      ]
    ))
  }

  /// Author
  ///
  /// Parent Type: `CollectionAuthor`
  public struct Author: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(CollectionAuthorSummary.self),
    ] }

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
          ObjectIdentifier(CollectionSummary.Author.self),
          ObjectIdentifier(CollectionAuthorSummary.self)
        ]
      ))
    }
  }
}
