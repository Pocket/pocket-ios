// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CorpusItemSummary: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CorpusItemSummary on CorpusItem { __typename publisher title }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("publisher", String.self),
    .field("title", String.self),
  ] }

  /// The name of the online publication that published this story.
  public var publisher: String { __data["publisher"] }
  /// The title of the Approved Item.
  public var title: String { __data["title"] }

  public init(
    publisher: String,
    title: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CorpusItem.typename,
        "publisher": publisher,
        "title": title,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CorpusItemSummary.self)
      ]
    ))
  }
}
