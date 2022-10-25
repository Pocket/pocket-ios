// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleTableParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleTableParts on MarticleTable {
      __typename
      html
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleTable }
  public static var __selections: [Selection] { [
    .field("html", String.self),
  ] }

  /// Raw HTML representation of the table.
  public var html: String { __data["html"] }
}
