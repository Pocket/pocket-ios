// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct EditNoteTitleInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: ID,
    title: String,
    updatedAt: GraphQLNullable<ISOString> = nil
  ) {
    __data = InputDict([
      "id": id,
      "title": title,
      "updatedAt": updatedAt
    ])
  }

  /// The ID of the note to edit
  public var id: ID {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  /// The new title for the note (can be an empty string)
  public var title: String {
    get { __data["title"] }
    set { __data["title"] = newValue }
  }

  /// When the update was made. If not provided, defaults to the server
  /// time upon receiving request.
  public var updatedAt: GraphQLNullable<ISOString> {
    get { __data["updatedAt"] }
    set { __data["updatedAt"] = newValue }
  }
}
