// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input field for upserting a SavedItem
public struct SavedItemUpsertInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    url: String,
    isFavorite: GraphQLNullable<Bool> = nil,
    timestamp: GraphQLNullable<Int> = nil
  ) {
    __data = InputDict([
      "url": url,
      "isFavorite": isFavorite,
      "timestamp": timestamp
    ])
  }

  /// The url to create/update the SavedItem with. (the url to save to the list)
  public var url: String {
    get { __data.url }
    set { __data.url = newValue }
  }

  /// Optional, create/update the SavedItem as a favorited item
  public var isFavorite: GraphQLNullable<Bool> {
    get { __data.isFavorite }
    set { __data.isFavorite = newValue }
  }

  /// Optional, time that request was submitted by client epoch/unix time
  public var timestamp: GraphQLNullable<Int> {
    get { __data.timestamp }
    set { __data.timestamp = newValue }
  }
}
