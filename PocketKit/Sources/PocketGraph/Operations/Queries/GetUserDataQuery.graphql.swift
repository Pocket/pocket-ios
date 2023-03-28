// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetUserDataQuery: GraphQLQuery {
  public static let operationName: String = "GetUserData"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetUserData {
        user {
          __typename
          isPremium
          username
          name
        }
      }
      """#
    ))

  public init() {}

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("user", User?.self),
    ] }

    /// Get a user entity for an authenticated client
    public var user: User? { __data["user"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("isPremium", Bool?.self),
        .field("username", String?.self),
        .field("name", String?.self),
      ] }

      /// The user's premium status
      public var isPremium: Bool? { __data["isPremium"] }
      /// The public username for the user
      public var username: String? { __data["username"] }
      /// The users first name and last name combined
      public var name: String? { __data["name"] }
    }
  }
}
