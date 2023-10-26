// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SlateLineup: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SlateLineup
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SlateLineup>>

  public struct MockFields {
    @Field<PocketGraph.ID>("experimentId") public var experimentId
    @Field<PocketGraph.ID>("id") public var id
    @Field<PocketGraph.ID>("requestId") public var requestId
    @Field<[Slate]>("slates") public var slates
  }
}

public extension Mock where O == SlateLineup {
  convenience init(
    experimentId: PocketGraph.ID? = nil,
    id: PocketGraph.ID? = nil,
    requestId: PocketGraph.ID? = nil,
    slates: [Mock<Slate>]? = nil
  ) {
    self.init()
    _setScalar(experimentId, for: \.experimentId)
    _setScalar(id, for: \.id)
    _setScalar(requestId, for: \.requestId)
    _setList(slates, for: \.slates)
  }
}
