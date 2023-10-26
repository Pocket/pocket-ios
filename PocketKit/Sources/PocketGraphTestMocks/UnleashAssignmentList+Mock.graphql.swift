// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class UnleashAssignmentList: MockObject {
  public static let objectType: Object = PocketGraph.Objects.UnleashAssignmentList
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UnleashAssignmentList>>

  public struct MockFields {
    @Field<[UnleashAssignment?]>("assignments") public var assignments
  }
}

public extension Mock where O == UnleashAssignmentList {
  convenience init(
    assignments: [Mock<UnleashAssignment>?]? = nil
  ) {
    self.init()
    _setList(assignments, for: \.assignments)
  }
}
