// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct DeleteNoteInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: ID,
    deletedAt: GraphQLNullable<ISOString> = nil
  ) {
    __data = InputDict([
      "id": id,
      "deletedAt": deletedAt
    ])
  }

  /// The ID of the note to delete
  public var id: ID {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  /// When the note was deleted was made. If not provided, defaults to
  /// the server time upon receiving request.
  public var deletedAt: GraphQLNullable<ISOString> {
    get { __data["deletedAt"] }
    set { __data["deletedAt"] = newValue }
  }
}
