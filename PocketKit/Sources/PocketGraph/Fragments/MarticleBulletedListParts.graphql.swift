// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleBulletedListParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleBulletedListParts on MarticleBulletedList { __typename rows { __typename content level } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBulletedList }
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
        "__typename": PocketGraph.Objects.MarticleBulletedList.typename,
        "rows": rows._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleBulletedListParts.self)
      ]
    ))
  }

  /// Row
  ///
  /// Parent Type: `BulletedListElement`
  public struct Row: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.BulletedListElement }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("content", PocketGraph.Markdown.self),
      .field("level", Int.self),
    ] }

    /// Row in a list.
    public var content: PocketGraph.Markdown { __data["content"] }
    /// Zero-indexed level, for handling nested lists.
    public var level: Int { __data["level"] }

    public init(
      content: PocketGraph.Markdown,
      level: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": PocketGraph.Objects.BulletedListElement.typename,
          "content": content,
          "level": level,
        ],
        fulfilledFragments: [
          ObjectIdentifier(MarticleBulletedListParts.Row.self)
        ]
      ))
    }
  }
}
