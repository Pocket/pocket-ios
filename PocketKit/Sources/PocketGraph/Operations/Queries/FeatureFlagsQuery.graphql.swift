// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FeatureFlagsQuery: GraphQLQuery {
  public static let operationName: String = "FeatureFlags"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FeatureFlags($context: UnleashContext!) { assignments: unleashAssignments(context: $context) { __typename assignments { __typename name assigned variant payload } } }"#
    ))

  public var context: UnleashContext

  public init(context: UnleashContext) {
    self.context = context
  }

  public var __variables: Variables? { ["context": context] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("unleashAssignments", alias: "assignments", Assignments?.self, arguments: ["context": .variable("context")]),
    ] }

    /// Returns a list of unleash toggles that are enabled for a given context.
    ///
    /// For more details on this check out https://docs.google.com/document/d/1dYS81h-DbQEWNLtK-ajLTylw454S32llPXUyBmDd5mU/edit# and https://getpocket.atlassian.net/wiki/spaces/PE/pages/1191444582/Feature+Flags+-+Unleash
    ///
    /// ~ For each of the enabled unleash toggles (via https://featureflags.readitlater.com/api/client/features or an unleash sdk)
    /// ~ Check if the toggle is assigned/enabled for the provided {.context}
    /// ~ Add an {UnleashAssignment} representing it to this list
    /// ~ If no toggles are found, return an empty list
    public var assignments: Assignments? { __data["assignments"] }

    /// Assignments
    ///
    /// Parent Type: `UnleashAssignmentList`
    public struct Assignments: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.UnleashAssignmentList }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("assignments", [Assignment?].self),
      ] }

      public var assignments: [Assignment?] { __data["assignments"] }

      /// Assignments.Assignment
      ///
      /// Parent Type: `UnleashAssignment`
      public struct Assignment: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.UnleashAssignment }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("assigned", Bool.self),
          .field("variant", String?.self),
          .field("payload", String?.self),
        ] }

        /// The unleash toggle name, the same name as it appears in the admin interface and feature api
        public var name: String { __data["name"] }
        /// Whether or not the provided context is assigned
        public var assigned: Bool { __data["assigned"] }
        /// If the toggle has variants, the variant name it is assigned to
        public var variant: String? { __data["variant"] }
        /// If the variant has a payload, its payload value
        public var payload: String? { __data["payload"] }
      }
    }
  }
}
