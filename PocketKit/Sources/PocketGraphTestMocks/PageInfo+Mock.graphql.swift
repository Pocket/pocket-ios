// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class PageInfo: MockObject {
  public static let objectType: Object = PocketGraph.Objects.PageInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PageInfo>>

  public struct MockFields {
    @Field<String?>("endCursor") public var endCursor
    @Field<Bool>("hasNextPage") public var hasNextPage
    @Field<Bool>("hasPreviousPage") public var hasPreviousPage
    @Field<String?>("startCursor") public var startCursor
  }
}

public extension Mock where O == PageInfo {
  convenience init(
    endCursor: String? = nil,
    hasNextPage: Bool,
    hasPreviousPage: Bool,
    startCursor: String? = nil
  ) {
    self.init()
    self.endCursor = endCursor
    self.hasNextPage = hasNextPage
    self.hasPreviousPage = hasPreviousPage
    self.startCursor = startCursor
  }
}
