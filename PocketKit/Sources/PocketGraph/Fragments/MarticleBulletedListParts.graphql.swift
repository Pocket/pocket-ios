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
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleBulletedList }
  public static var __selections: [Selection] { [
    .field("rows", [Row].self),
  ] }

  public var rows: [Row] { __data["rows"] }

  /// Row
  ///
  /// Parent Type: `BulletedListElement`
  public struct Row: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.BulletedListElement }
    public static var __selections: [Selection] { [
      .field("content", Markdown.self),
      .field("level", Int.self),
    ] }

    /// Row in a list.
    public var content: Markdown { __data["content"] }
    /// Zero-indexed level, for handling nested lists.
    public var level: Int { __data["level"] }
  }
}
