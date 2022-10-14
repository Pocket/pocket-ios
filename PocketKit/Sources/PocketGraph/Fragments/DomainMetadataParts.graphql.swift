// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct DomainMetadataParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DomainMetadataParts on DomainMetadata {
      __typename
      name
      logo
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.DomainMetadata }
  public static var __selections: [Selection] { [
    .field("name", String?.self),
    .field("logo", Url?.self),
  ] }

  /// The name of the domain (e.g., The New York Times)
  public var name: String? { __data["name"] }
  /// Url for the logo image
  public var logo: Url? { __data["logo"] }
}
