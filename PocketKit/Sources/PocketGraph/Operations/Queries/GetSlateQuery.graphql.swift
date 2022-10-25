// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSlateQuery: GraphQLQuery {
  public static let operationName: String = "GetSlate"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query GetSlate($slateID: String!, $recommendationCount: Int!) {
        getSlate(slateId: $slateID, recommendationCount: $recommendationCount) {
          __typename
          ...SlateParts
        }
      }
      """,
      fragments: [SlateParts.self, ItemSummary.self, DomainMetadataParts.self, CuratedInfoParts.self]
    ))

  public var slateID: String
  public var recommendationCount: Int

  public init(
    slateID: String,
    recommendationCount: Int
  ) {
    self.slateID = slateID
    self.recommendationCount = recommendationCount
  }

  public var __variables: Variables? { [
    "slateID": slateID,
    "recommendationCount": recommendationCount
  ] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { PocketGraph.Objects.Query }
    public static var __selections: [Selection] { [
      .field("getSlate", GetSlate?.self, arguments: [
        "slateId": .variable("slateID"),
        "recommendationCount": .variable("recommendationCount")
      ]),
    ] }

    /// Request a specific `Slate` by id
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    public var getSlate: GetSlate? { __data["getSlate"] }

    /// GetSlate
    ///
    /// Parent Type: `Slate`
    public struct GetSlate: PocketGraph.SelectionSet {
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
