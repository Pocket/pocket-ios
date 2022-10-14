// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input field for setting all Tag associations on a SavedItem.
public struct SavedItemTagsInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    savedItemId: ID,
    tags: [String]
  ) {
    __data = InputDict([
      "savedItemId": savedItemId,
      "tags": tags
    ])
  }

  /// The SavedItem ID to associate Tags to
  public var savedItemId: ID {
    get { __data.savedItemId }
    set { __data.savedItemId = newValue }
  }

  /// The set of Tag names to associate to the SavedItem
  public var tags: [String] {
    get { __data.tags }
    set { __data.tags = newValue }
  }
}
