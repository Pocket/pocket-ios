// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CollectionAuthorSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CollectionAuthorSummary on CollectionAuthor { __typename name }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("name", String.self),
  ] }

  public var name: String { __data["name"] }

  public init(
    name: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CollectionAuthor.typename,
        "name": name,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CollectionAuthorSummary.self)
      ]
    ))
  }
}
