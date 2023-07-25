// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CollectionSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CollectionSummary on Collection {
      __typename
      slug
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("slug", String.self),
  ] }

  public var slug: String { __data["slug"] }

  public init(
    slug: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.Collection.typename,
        "slug": slug,
      ],
      fulfilledFragments: [
        ObjectIdentifier(Self.self)
      ]
    ))
  }
}
