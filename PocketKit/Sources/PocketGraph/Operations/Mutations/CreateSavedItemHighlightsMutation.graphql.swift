// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateSavedItemHighlightsMutation: GraphQLMutation {
  public static let operationName: String = "CreateSavedItemHighlights"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateSavedItemHighlights($input: [CreateHighlightInput!]!) { createSavedItemHighlights(input: $input) { __typename ...HighlightParts } }"#,
      fragments: [HighlightParts.self]
    ))

  public var input: [CreateHighlightInput]

  public init(input: [CreateHighlightInput]) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createSavedItemHighlights", [CreateSavedItemHighlight].self, arguments: ["input": .variable("input")]),
    ] }

    /// Create new highlight annotation(s). Returns the data for the created Highlight object(s).
    public var createSavedItemHighlights: [CreateSavedItemHighlight] { __data["createSavedItemHighlights"] }

    /// CreateSavedItemHighlight
    ///
    /// Parent Type: `Highlight`
    public struct CreateSavedItemHighlight: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Highlight }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(HighlightParts.self),
      ] }

      /// When the Highlight was created
      public var _createdAt: PocketGraph.Timestamp { __data["_createdAt"] }
      /// When the highlight was last updated
      public var _updatedAt: PocketGraph.Timestamp { __data["_updatedAt"] }
      /// Patch string generated by 'DiffMatchPatch' library, serialized
      /// into text via `patch_toText` method. Use `patch_fromText` to
      /// deserialize into an object that can be used by the DiffMatchPatch
      /// library. Format is similar to UniDiff but is character-based.
      /// The patched text depends on version. For example, the version 2
      /// patch surrounds the highlighted text portion with a pair of
      /// sentinel tags: '<pkt_tag_annotation></pkt_tag_annotation>'
      /// Reference: https://github.com/google/diff-match-patch
      public var patch: String { __data["patch"] }
      /// The full text of the highlighted passage. Used as a fallback for
      /// rendering highlight if the patch fails.
      public var quote: String { __data["quote"] }
      /// Version number for highlight data specification
      public var version: Int { __data["version"] }
      /// The ID for this Highlight annotation
      public var id: PocketGraph.ID { __data["id"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var highlightParts: HighlightParts { _toFragment() }
      }
    }
  }
}