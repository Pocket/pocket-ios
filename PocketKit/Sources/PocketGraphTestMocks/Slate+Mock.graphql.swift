// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Slate: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Slate
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Slate>>

  public struct MockFields {
    @Field<String>("description") public var description
    @Field<String>("displayName") public var displayName
    @Field<PocketGraph.ID>("experimentId") public var experimentId
    @Field<String>("id") public var id
    @Field<[Recommendation]>("recommendations") public var recommendations
    @Field<PocketGraph.ID>("requestId") public var requestId
  }
}

public extension Mock where O == Slate {
  convenience init(
    description: String? = nil,
    displayName: String? = nil,
    experimentId: PocketGraph.ID? = nil,
    id: String? = nil,
    recommendations: [Mock<Recommendation>]? = nil,
    requestId: PocketGraph.ID? = nil
  ) {
    self.init()
    _setScalar(description, for: \.description)
    _setScalar(displayName, for: \.displayName)
    _setScalar(experimentId, for: \.experimentId)
    _setScalar(id, for: \.id)
    _setList(recommendations, for: \.recommendations)
    _setScalar(requestId, for: \.requestId)
  }
}
