// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleHeading: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.MarticleHeading
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleHeading>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("content") public var content
    @Field<Int>("level") public var level
  }
}

public extension Mock where O == MarticleHeading {
  convenience init(
    content: PocketGraph.Markdown? = nil,
    level: Int? = nil
  ) {
    self.init()
    _setScalar(content, for: \.content)
    _setScalar(level, for: \.level)
  }
}
