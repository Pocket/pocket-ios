// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemConnection: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.SavedItemConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemConnection>>

  public struct MockFields {
    @Field<[SavedItemEdge?]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == SavedItemConnection {
  convenience init(
    edges: [Mock<SavedItemEdge>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
