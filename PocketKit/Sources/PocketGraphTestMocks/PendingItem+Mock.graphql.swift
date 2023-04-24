// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class PendingItem: MockObject {
  public static let objectType: Object = PocketGraph.Objects.PendingItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PendingItem>>

  public struct MockFields {
    @Field<PocketGraph.Url>("givenUrl") public var givenUrl
    @Field<String>("remoteID") public var remoteID
    @Field<GraphQLEnum<PocketGraph.PendingItemStatus>>("status") public var status
  }
}

public extension Mock where O == PendingItem {
  convenience init(
    givenUrl: PocketGraph.Url? = nil,
    remoteID: String? = nil,
    status: GraphQLEnum<PocketGraph.PendingItemStatus>? = nil
  ) {
    self.init()
    self.givenUrl = givenUrl
    self.remoteID = remoteID
    self.status = status
  }
}
