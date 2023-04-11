// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleBulletedListParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleBulletedListParts on MarticleBulletedList {
      __typename
      rows {
        __typename
        content
        level
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBulletedList }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("rows", [Row].self),
  ] }

  public var rows: [Row] { __data["rows"] }

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
  }
}
