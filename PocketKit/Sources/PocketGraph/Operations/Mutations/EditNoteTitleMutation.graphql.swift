// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class EditNoteTitleMutation: GraphQLMutation {
  public static let operationName: String = "EditNoteTitle"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation EditNoteTitle($input: EditNoteTitleInput!) { editNoteTitle(input: $input) { __typename ...NotesPart } }"#,
      fragments: [NotesPart.self]
    ))

  public var input: EditNoteTitleInput

  public init(input: EditNoteTitleInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("editNoteTitle", EditNoteTitle?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Edit the title of a Note.
    /// If the Note does not exist or is inaccessible for the current user,
    /// response will be null and a NOT_FOUND error will be included in the
    /// errors array.
    public var editNoteTitle: EditNoteTitle? { __data["editNoteTitle"] }

    /// EditNoteTitle
    ///
    /// Parent Type: `Note`
    public struct EditNoteTitle: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Note }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(NotesPart.self),
      ] }

      /// Markdown preview of the note content for summary view.
      public var contentPreview: PocketGraph.Markdown? { __data["contentPreview"] }
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

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var notesPart: NotesPart { _toFragment() }
      }

      public typealias SavedItem = NotesPart.SavedItem
    }
  }
}
