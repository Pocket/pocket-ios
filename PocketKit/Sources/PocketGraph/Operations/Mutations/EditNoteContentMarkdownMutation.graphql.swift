// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class EditNoteContentMarkdownMutation: GraphQLMutation {
  public static let operationName: String = "EditNoteContentMarkdown"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation EditNoteContentMarkdown($input: EditNoteContentMarkdownInput!) { editNoteContentMarkdown(input: $input) { __typename ...NotesPart } }"#,
      fragments: [NotesPart.self]
    ))

  public var input: EditNoteContentMarkdownInput

  public init(input: EditNoteContentMarkdownInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("editNoteContentMarkdown", EditNoteContentMarkdown?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Edit the content of a Note, providing a markdown document instead
    /// of a Prosemirror JSON.
    /// If the Note does not exist or is inaccessible for the current user,
    /// response will be null and a NOT_FOUND error will be included in the
    /// errors array.
    public var editNoteContentMarkdown: EditNoteContentMarkdown? { __data["editNoteContentMarkdown"] }

    /// EditNoteContentMarkdown
    ///
    /// Parent Type: `Note`
    public struct EditNoteContentMarkdown: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Note }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(NotesPart.self),
      ] }

      /// Markdown preview of the note content for summary view.
      public var contentPreview: PocketGraph.Markdown? { __data["contentPreview"] }
      /// Markdown representation of the note content
      public var docMarkdown: PocketGraph.Markdown? { __data["docMarkdown"] }
      /// When this note was created
      public var createdAt: PocketGraph.ISOString { __data["createdAt"] }
      /// This Note's identifier
      public var id: PocketGraph.ID { __data["id"] }
      /// The SavedItem entity this note is attached to (either directly
      /// or via a Clipping, if applicable)
      public var savedItem: SavedItem? { __data["savedItem"] }
      /// The URL this entity was created from (either directly or via
      /// a Clipping, if applicable).
      public var source: PocketGraph.ValidUrl? { __data["source"] }
      /// Title of this note
      public var title: String? { __data["title"] }
      /// When this note was last updated
      public var updatedAt: PocketGraph.ISOString { __data["updatedAt"] }
      /// Whether this Note has been marked as archived (hide from default view).
      public var archived: Bool { __data["archived"] }
      /// Whether this Note has been marked for deletion (will be eventually
      /// removed from the server). Clients should delete Notes from their local
      /// storage if this value is true.
      public var deleted: Bool { __data["deleted"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var notesPart: NotesPart { _toFragment() }
      }

      public typealias SavedItem = NotesPart.SavedItem
    }
  }
}
