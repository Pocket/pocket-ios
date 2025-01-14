// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NoteQuery: GraphQLQuery {
  public static let operationName: String = "Note"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Note($noteId: ID!) { note(id: $noteId) { __typename ...NotesPart } }"#,
      fragments: [NotesPart.self]
    ))

  public var noteId: ID

  public init(noteId: ID) {
    self.noteId = noteId
  }

  public var __variables: Variables? { ["noteId": noteId] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("note", Note?.self, arguments: ["id": .variable("noteId")]),
    ] }

    /// Retrieve a specific Note
    public var note: Note? { __data["note"] }

    /// Note
    ///
    /// Parent Type: `Note`
    public struct Note: PocketGraph.SelectionSet {
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
