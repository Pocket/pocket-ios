// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input for editing the content of a Note (user-generated),
/// providing the content as a Markdown-formatted string.
public struct EditNoteContentMarkdownInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    noteId: ID,
    docMarkdown: Markdown,
    updatedAt: GraphQLNullable<ISOString> = nil
  ) {
    __data = InputDict([
      "noteId": noteId,
      "docMarkdown": docMarkdown,
      "updatedAt": updatedAt
    ])
  }

  /// The ID of the note to edit
  public var noteId: ID {
    get { __data["noteId"] }
    set { __data["noteId"] = newValue }
  }

  /// Commonmark Markdown string representing the document content.
  public var docMarkdown: Markdown {
    get { __data["docMarkdown"] }
    set { __data["docMarkdown"] = newValue }
  }

  /// The time this update was made (defaults to server time)
  public var updatedAt: GraphQLNullable<ISOString> {
    get { __data["updatedAt"] }
    set { __data["updatedAt"] = newValue }
  }
}
