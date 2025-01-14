// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class NoteConnection: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.NoteConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<NoteConnection>>

  public struct MockFields {
    @Field<[NoteEdge?]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == NoteConnection {
  convenience init(
    edges: [Mock<NoteEdge>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
