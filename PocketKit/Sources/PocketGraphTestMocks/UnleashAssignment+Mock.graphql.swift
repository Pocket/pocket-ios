// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class UnleashAssignment: MockObject {
  public static let objectType: Object = PocketGraph.Objects.UnleashAssignment
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UnleashAssignment>>

  public struct MockFields {
    @Field<Bool>("assigned") public var assigned
    @Field<String>("name") public var name
    @Field<String?>("payload") public var payload
    @Field<String?>("variant") public var variant
  }
}

public extension Mock where O == UnleashAssignment {
  convenience init(
    assigned: Bool,
    name: String,
    payload: String? = nil,
    variant: String? = nil
  ) {
    self.init()
    _set(assigned, for: \.assigned)
    _set(name, for: \.name)
    _set(payload, for: \.payload)
    _set(variant, for: \.variant)
  }
}
