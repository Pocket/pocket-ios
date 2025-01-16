// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Filter for retrieving Notes
public struct NoteFilterInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    isAttachedToSave: GraphQLNullable<Bool> = nil,
    archived: GraphQLNullable<Bool> = nil,
    since: GraphQLNullable<ISOString> = nil,
    excludeDeleted: GraphQLNullable<Bool> = nil
  ) {
    __data = InputDict([
      "isAttachedToSave": isAttachedToSave,
      "archived": archived,
      "since": since,
      "excludeDeleted": excludeDeleted
    ])
  }

  /// Filter to show notes which are attached to a source URL
  /// directly or via clipping, or are standalone
  /// notes. If not provided, notes will not be filtered by source url.
  public var isAttachedToSave: GraphQLNullable<Bool> {
    get { __data["isAttachedToSave"] }
    set { __data["isAttachedToSave"] = newValue }
  }

  /// Filter to retrieve Notes by archived status (true/false).
  /// If not provided, notes will not be filtered by archived status.
  public var archived: GraphQLNullable<Bool> {
    get { __data["archived"] }
    set { __data["archived"] = newValue }
  }

  /// Filter to retrieve notes after a timestamp, e.g. for syncing.
  public var since: GraphQLNullable<ISOString> {
    get { __data["since"] }
    set { __data["since"] = newValue }
  }

  /// Filter to choose whether to include notes marked for server-side
  /// deletion in the response (defaults to false).
  public var excludeDeleted: GraphQLNullable<Bool> {
    get { __data["excludeDeleted"] }
    set { __data["excludeDeleted"] = newValue }
  }
}
