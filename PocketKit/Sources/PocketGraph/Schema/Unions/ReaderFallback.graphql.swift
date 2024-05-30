// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Metadata of an Item in Pocket for preview purposes,
  /// or an ItemNotFound result if the record does not exist.
  static let ReaderFallback = Union(
    name: "ReaderFallback",
    possibleTypes: [
      Objects.ReaderInterstitial.self,
      Objects.ItemNotFound.self
    ]
  )
}