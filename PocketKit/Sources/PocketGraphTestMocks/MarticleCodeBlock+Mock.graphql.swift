// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleCodeBlock: MockObject {
  public static let objectType: Object = PocketGraph.Objects.MarticleCodeBlock
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleCodeBlock>>

  public struct MockFields {
    @Field<Int>("language") public var language
    @Field<String>("text") public var text
  }
}

public extension Mock where O == MarticleCodeBlock {
  convenience init(
    language: Int? = nil,
    text: String? = nil
  ) {
    self.init()
    _setScalar(language, for: \.language)
    _setScalar(text, for: \.text)
  }
}
