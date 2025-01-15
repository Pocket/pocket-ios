// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class NoteEdge: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.NoteEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<NoteEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<Note>("node") public var node
  }
}

public extension Mock where O == NoteEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<Note>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
