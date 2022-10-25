// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input field for updating a Tag
public struct TagUpdateInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: ID,
    name: String
  ) {
    __data = InputDict([
      "id": id,
      "name": name
    ])
  }

  /// Tag ID
  public var id: ID {
    get { __data.id }
    set { __data.id = newValue }
  }

  /// The updated tag string
  public var name: String {
    get { __data.name }
    set { __data.name = newValue }
  }
}
