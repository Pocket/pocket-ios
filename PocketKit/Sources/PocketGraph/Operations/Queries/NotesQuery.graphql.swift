// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NotesQuery: GraphQLQuery {
  public static let operationName: String = "Notes"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Notes { notes { __typename edges { __typename cursor node { __typename ...NotesPart } } pageInfo { __typename endCursor hasNextPage hasPreviousPage startCursor } totalCount } }"#,
      fragments: [NotesPart.self]
    ))

  public init() {}

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("notes", Notes?.self),
    ] }

    /// Retrieve a user's Notes
    public var notes: Notes? { __data["notes"] }

    /// Notes
    ///
    /// Parent Type: `NoteConnection`
    public struct Notes: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.NoteConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge?]?.self),
        .field("pageInfo", PageInfo.self),
        .field("totalCount", Int.self),
      ] }

      /// A list of edges.
      public var edges: [Edge?]? { __data["edges"] }
      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Identifies the total count of Notes in the connection.
      public var totalCount: Int { __data["totalCount"] }

      /// Notes.Edge
      ///
      /// Parent Type: `NoteEdge`
      public struct Edge: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.NoteEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination.
        public var cursor: String { __data["cursor"] }
        /// The Note at the end of the edge.
        public var node: Node? { __data["node"] }

        /// Notes.Edge.Node
        ///
        /// Parent Type: `Note`
        public struct Node: PocketGraph.SelectionSet {
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

      /// Notes.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("endCursor", String?.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("startCursor", String?.self),
        ] }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? { __data["startCursor"] }
      }
    }
  }
}
