// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Input to create a new Note with markdown-formatted
/// content string.
public struct CreateNoteMarkdownInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    title: GraphQLNullable<String> = nil,
    id: GraphQLNullable<ID> = nil,
    source: GraphQLNullable<ValidUrl> = nil,
    docMarkdown: Markdown,
    createdAt: GraphQLNullable<ISOString> = nil
  ) {
    __data = InputDict([
      "title": title,
      "id": id,
      "source": source,
      "docMarkdown": docMarkdown,
      "createdAt": createdAt
    ])
  }

  /// Optional title for this Note
  public var title: GraphQLNullable<String> {
    get { __data["title"] }
    set { __data["title"] = newValue }
  }

  /// Client-provided UUID for the new Note.
  /// If not provided, will be generated on the server.
  public var id: GraphQLNullable<ID> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  /// Optional URL to link this Note to.
  public var source: GraphQLNullable<ValidUrl> {
    get { __data["source"] }
    set { __data["source"] = newValue }
  }

  /// The document content in Commonmark Markdown.
  public var docMarkdown: Markdown {
    get { __data["docMarkdown"] }
    set { __data["docMarkdown"] = newValue }
  }

  /// When this note was created. If not provided, defaults to server time upon
  /// receiving request.
  public var createdAt: GraphQLNullable<ISOString> {
    get { __data["createdAt"] }
    set { __data["createdAt"] = newValue }
  }
}
