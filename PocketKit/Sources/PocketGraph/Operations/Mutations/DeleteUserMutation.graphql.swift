// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteUserMutation: GraphQLMutation {
  public static let operationName: String = "DeleteUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteUser { deleteUser }"#
    ))

  public init() {}

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteUser", PocketGraph.ID.self),
    ] }

    /// Deletes user information and their pocket data for the given pocket userId. Returns pocket userId.
    public var deleteUser: PocketGraph.ID { __data["deleteUser"] }
  }
}
