// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSlateLineupQuery: GraphQLQuery {
  public static let operationName: String = "GetSlateLineup"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query GetSlateLineup($lineupID: String!, $maxRecommendations: Int!) {
        getSlateLineup(
          slateLineupId: $lineupID
          recommendationCount: $maxRecommendations
        ) {
          __typename
          id
          requestId
          experimentId
          slates {
            __typename
            ...SlateParts
          }
        }
      }
      """,
      fragments: [SlateParts.self, ItemSummary.self, DomainMetadataParts.self, CuratedInfoParts.self]
    ))

  public var lineupID: String
  public var maxRecommendations: Int

  public init(
    lineupID: String,
    maxRecommendations: Int
  ) {
    self.lineupID = lineupID
    self.maxRecommendations = maxRecommendations
  }

  public var __variables: Variables? { [
    "lineupID": lineupID,
    "maxRecommendations": maxRecommendations
  ] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Query }
    public static var __selections: [Selection] { [
      .field("getSlateLineup", GetSlateLineup?.self, arguments: [
        "slateLineupId": .variable("lineupID"),
        "recommendationCount": .variable("maxRecommendations")
      ]),
    ] }

    /// Request a specific `SlateLineup` by id
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    public var getSlateLineup: GetSlateLineup? { __data["getSlateLineup"] }

    /// GetSlateLineup
    ///
    /// Parent Type: `SlateLineup`
    public struct GetSlateLineup: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { PocketGraph.Objects.SlateLineup }
      public static var __selections: [Selection] { [
        .field("id", ID.self),
        .field("requestId", ID.self),
        .field("experimentId", ID.self),
        .field("slates", [Slate].self),
      ] }

      /// A unique slug/id that describes a SlateLineup. The Data & Learning team will provide apps what id to use here for specific cases.
      public var id: ID { __data["id"] }
      /// A guid that is unique to every API request that returned slates, such as `getRecommendationSlateLineup` or `getSlate`. The API will provide a new request id every time apps hit the API.
      public var requestId: ID { __data["requestId"] }
      /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment. Production apps typically won't request a specific one, but can for QA or during a/b testing.
      public var experimentId: ID { __data["experimentId"] }
      /// An ordered list of slates for the client to display
      public var slates: [Slate] { __data["slates"] }

      /// GetSlateLineup.Slate
      ///
      /// Parent Type: `Slate`
      public struct Slate: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { PocketGraph.Objects.Slate }
        public static var __selections: [Selection] { [
          .fragment(SlateParts.self),
        ] }

        public var id: String { __data["id"] }
        /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`. The API will provide a new request id every time apps hit the API.
        public var requestId: ID { __data["requestId"] }
        /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment. Production apps typically won't request a specific one, but can for QA or during a/b testing.
        public var experimentId: ID { __data["experimentId"] }
        /// The name to show to the user for this set of recommendations
        public var displayName: String? { __data["displayName"] }
        /// The description of the the slate
        public var description: String? { __data["description"] }
        /// An ordered list of the recommendations to show to the user
        public var recommendations: [SlateParts.Recommendation] { __data["recommendations"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var slateParts: SlateParts { _toFragment() }
        }
      }
    }
  }
}
