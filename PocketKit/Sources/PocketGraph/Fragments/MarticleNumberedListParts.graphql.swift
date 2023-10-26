// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleNumberedListParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleNumberedListParts on MarticleNumberedList { __typename rows { __typename content level index } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleNumberedList }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("rows", [Row].self),
  ] }

  public var rows: [Row] { __data["rows"] }

  public init(
    rows: [Row]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleNumberedList.typename,
        "rows": rows._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleNumberedListParts.self)
      ]
    ))
  }

  /// Row
  ///
  /// Parent Type: `NumberedListElement`
  public struct Row: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.NumberedListElement }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("content", PocketGraph.Markdown.self),
      .field("level", Int.self),
      .field("index", Int.self),
    ] }

    /// Row in a list
    public var content: PocketGraph.Markdown { __data["content"] }
    /// Zero-indexed level, for handling nested lists.
    public var level: Int { __data["level"] }
    /// Numeric index. If a nested item, the index is zero-indexed from the first child.
    public var index: Int { __data["index"] }

    public init(
      content: PocketGraph.Markdown,
      level: Int,
      index: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.NumberedListElement.typename,
          "content": content,
          "level": level,
          "index": index,
        ],
        fulfilledFragments: [
          ObjectIdentifier(MarticleNumberedListParts.Row.self)
        ]
      ))
    }
  }
}
