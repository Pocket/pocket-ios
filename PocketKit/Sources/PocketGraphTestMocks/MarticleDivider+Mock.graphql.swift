// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleDivider: MockObject {
  public static let objectType: Object = PocketGraph.Objects.MarticleDivider
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleDivider>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("content") public var content
  }
}

public extension Mock where O == MarticleDivider {
  convenience init(
    content: PocketGraph.Markdown? = nil
  ) {
    self.init()
    _setScalar(content, for: \.content)
  }
}
