// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input field for adding Tag Associations to a SavedItem, by givenUrl
public struct SavedItemTagInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    givenUrl: Url,
    tagNames: [String]
  ) {
    __data = InputDict([
      "givenUrl": givenUrl,
      "tagNames": tagNames
    ])
  }

  public var givenUrl: Url {
    get { __data["givenUrl"] }
    set { __data["givenUrl"] = newValue }
  }

  public var tagNames: [String] {
    get { __data["tagNames"] }
    set { __data["tagNames"] = newValue }
  }
}
