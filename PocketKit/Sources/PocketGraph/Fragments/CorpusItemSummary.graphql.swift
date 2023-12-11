// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusItemSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CorpusItemSummary on CorpusItem { __typename publisher }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("publisher", String.self),
  ] }

  /// The name of the online publication that published this story.
  public var publisher: String { __data["publisher"] }

  public init(
    publisher: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CorpusItem.typename,
        "publisher": publisher,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CorpusItemSummary.self)
      ]
    ))
  }
}
