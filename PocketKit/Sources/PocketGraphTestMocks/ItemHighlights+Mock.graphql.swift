// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class ItemHighlights: MockObject {
  public static let objectType: Object = PocketGraph.Objects.ItemHighlights
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ItemHighlights>>

  public struct MockFields {
    @Field<[String?]>("full_text") public var full_text
    @Field<[String?]>("tags") public var tags
    @Field<[String?]>("title") public var title
    @Field<[String?]>("url") public var url
  }
}

public extension Mock where O == ItemHighlights {
  convenience init(
    full_text: [String]? = nil,
    tags: [String]? = nil,
    title: [String]? = nil,
    url: [String]? = nil
  ) {
    self.init()
    _set(full_text, for: \.full_text)
    _set(tags, for: \.tags)
    _set(title, for: \.title)
    _set(url, for: \.url)
  }
}
