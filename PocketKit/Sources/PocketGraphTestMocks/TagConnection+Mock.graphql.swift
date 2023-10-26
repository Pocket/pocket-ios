// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class TagConnection: MockObject {
  public static let objectType: Object = PocketGraph.Objects.TagConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<TagConnection>>

  public struct MockFields {
    @Field<[TagEdge?]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == TagConnection {
  convenience init(
    edges: [Mock<TagEdge>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
