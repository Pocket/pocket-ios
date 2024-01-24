// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteSavedItemHighlightMutation: GraphQLMutation {
  public static let operationName: String = "DeleteSavedItemHighlight"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteSavedItemHighlight($highlightId: ID!) { deleteSavedItemHighlight(id: $highlightId) }"#
    ))

  public var highlightId: ID

  public init(highlightId: ID) {
    self.highlightId = highlightId
  }

  public var __variables: Variables? { ["highlightId": highlightId] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteSavedItemHighlight", PocketGraph.ID.self, arguments: ["id": .variable("highlightId")]),
    ] }

    /// Delete a highlight by its ID.
    public var deleteSavedItemHighlight: PocketGraph.ID { __data["deleteSavedItemHighlight"] }
  }
}
