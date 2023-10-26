// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DomainMetadataParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment DomainMetadataParts on DomainMetadata { __typename name logo }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.DomainMetadata }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("name", String?.self),
    .field("logo", PocketGraph.Url?.self),
  ] }

  /// The name of the domain (e.g., The New York Times)
  public var name: String? { __data["name"] }
  /// Url for the logo image
  public var logo: PocketGraph.Url? { __data["logo"] }

  public init(
    name: String? = nil,
    logo: PocketGraph.Url? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.DomainMetadata.typename,
        "name": name,
        "logo": logo,
      ],
      fulfilledFragments: [
        ObjectIdentifier(DomainMetadataParts.self)
      ]
    ))
  }
}
