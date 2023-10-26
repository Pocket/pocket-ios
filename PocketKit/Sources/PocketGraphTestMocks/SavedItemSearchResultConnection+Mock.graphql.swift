// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemSearchResultConnection: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SavedItemSearchResultConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemSearchResultConnection>>

  public struct MockFields {
    @Field<[SavedItemSearchResultEdge]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == SavedItemSearchResultConnection {
  convenience init(
    edges: [Mock<SavedItemSearchResultEdge>]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
