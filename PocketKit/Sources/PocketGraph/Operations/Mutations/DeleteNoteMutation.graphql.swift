// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteNoteMutation: GraphQLMutation {
  public static let operationName: String = "DeleteNote"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteNote($input: DeleteNoteInput!) { deleteNote(input: $input) }"#
    ))

  public var input: DeleteNoteInput

  public init(input: DeleteNoteInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteNote", PocketGraph.ID.self, arguments: ["input": .variable("input")]),
    ] }

    /// Delete a note and all attachments. Returns True if the note was successfully
    /// deleted. If the note cannot be deleted or does not exist, returns False. 
    /// Errors will be included in the errors array if applicable.
    public var deleteNote: PocketGraph.ID { __data["deleteNote"] }
  }
}
