// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Query: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<UnleashAssignmentList>("assignments") public var assignments
    @Field<Collection>("collection") public var collection
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    @Field<Slate>("getSlate") public var getSlate
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    @Field<SlateLineup>("getSlateLineup") public var getSlateLineup
    @Field<Item>("itemByItemId") public var itemByItemId
    @Field<User>("user") public var user
  }
}

public extension Mock where O == Query {
  convenience init(
    assignments: Mock<UnleashAssignmentList>? = nil,
    collection: Mock<Collection>? = nil,
    getSlate: Mock<Slate>? = nil,
    getSlateLineup: Mock<SlateLineup>? = nil,
    itemByItemId: Mock<Item>? = nil,
    user: Mock<User>? = nil
  ) {
    self.init()
    _set(assignments, for: \.assignments)
    _set(collection, for: \.collection)
    _set(getSlate, for: \.getSlate)
    _set(getSlateLineup, for: \.getSlateLineup)
    _set(itemByItemId, for: \.itemByItemId)
    _set(user, for: \.user)
  }
}
