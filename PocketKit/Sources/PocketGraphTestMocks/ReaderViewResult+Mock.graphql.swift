// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class ReaderViewResult: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.ReaderViewResult
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ReaderViewResult>>

  public struct MockFields {
    @Field<ReaderFallback>("fallbackPage") public var fallbackPage
    @Field<SavedItem>("savedItem") public var savedItem
  }
}

public extension Mock where O == ReaderViewResult {
  convenience init(
    fallbackPage: AnyMock? = nil,
    savedItem: Mock<SavedItem>? = nil
  ) {
    self.init()
    _setEntity(fallbackPage, for: \.fallbackPage)
    _setEntity(savedItem, for: \.savedItem)
  }
}
