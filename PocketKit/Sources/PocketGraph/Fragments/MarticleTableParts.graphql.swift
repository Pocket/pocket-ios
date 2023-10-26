// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleTableParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleTableParts on MarticleTable { __typename html }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleTable }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("html", String.self),
  ] }

  /// Raw HTML representation of the table.
  public var html: String { __data["html"] }

  public init(
    html: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleTable.typename,
        "html": html,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleTableParts.self)
      ]
    ))
  }
}
