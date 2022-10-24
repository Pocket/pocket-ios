// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleHeadingParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleHeadingParts on MarticleHeading {
      __typename
      content
      level
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleHeading }
  public static var __selections: [Selection] { [
    .field("content", Markdown.self),
    .field("level", Int.self),
  ] }

  /// Heading text, in markdown.
  public var content: Markdown { __data["content"] }
  /// Heading level. Restricted to values 1-6.
  public var level: Int { __data["level"] }
}
