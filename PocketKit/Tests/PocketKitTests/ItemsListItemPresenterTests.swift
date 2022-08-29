import XCTest
@testable import Textile
@testable import PocketKit

class ItemsListItemPresenterTests: XCTestCase { }

// MARK: - Attributed Title
extension ItemsListItemPresenterTests {
    func test_attributedTitle_withItemTitle_usesTitle() {
        let item = MockItemsListItem.build(title: "Test Title")
        let presenter = ItemsListItemPresenter(item: item)

        XCTAssertEqual(presenter.attributedTitle.string, "Test Title")
    }

    func test_attributedTitle_noItemTitle_usesBestURL() {
        let item = MockItemsListItem.build(bestURL: URL(string: "https://getpocket.com")!)
        let presenter = ItemsListItemPresenter(item: item)

        XCTAssertEqual(presenter.attributedTitle.string, "https://getpocket.com")
    }

    func test_attributedTitle_whenItemIsNotPending_usesCorrectStyle() {
        let item = MockItemsListItem.build(title: "Pocket")
        let presenter = ItemsListItemPresenter(item: item)

        let style = presenter.attributedTitle.attributes(at: 0, effectiveRange: nil)[.style] as! Style
        XCTAssertEqual(UIColor(style.colorAsset), UIColor(.ui.grey1))
    }

    func test_attributedTitle_whenItemIsPending_usesCorrectStyle() {
        let item = MockItemsListItem.build(title: "Pocket", isPending: true)
        let presenter = ItemsListItemPresenter(item: item)

        let style = presenter.attributedTitle.attributes(at: 0, effectiveRange: nil)[.style] as! Style
        XCTAssertEqual(UIColor(style.colorAsset), UIColor(.ui.grey5))
    }
}

// MARK: - Attributed Detail
extension ItemsListItemPresenterTests {
    func test_attributedDetail_withDomainMetadata_usesName() {
        let item = MockItemsListItem.build(
            domainMetadata: MockItemsListItemDomainMetadata(name: "Pocket Domain")
        )
        let presenter = ItemsListItemPresenter(item: item)

        XCTAssertEqual(presenter.attributedDetail.string, "Pocket Domain")
    }

    func test_attributedDetail_noDomainMetatada_usesDomain() {
        let item = MockItemsListItem.build(domain: "getpocket.com")
        let presenter = ItemsListItemPresenter(item: item)

        XCTAssertEqual(presenter.attributedDetail.string, "getpocket.com")
    }

    func test_attributedDetail_noDomainMetadataOrName_usesHost() {
        let item = MockItemsListItem.build(host: "getpocket.com")
        let presenter = ItemsListItemPresenter(item: item)

        XCTAssertEqual(presenter.attributedDetail.string, "getpocket.com")
    }

    func test_attributedDetail_whenItemIsNotPending_usesCorrectStyle() {
        let item = MockItemsListItem.build(domain: "Pocket")
        let presenter = ItemsListItemPresenter(item: item)

        let style = presenter.attributedDetail.attributes(at: 0, effectiveRange: nil)[.style] as! Style
        XCTAssertEqual(UIColor(style.colorAsset), UIColor(.ui.grey4))
    }

    func test_attributedDetail_whenItemIsPending_usesCorrectStyle() {
        let item = MockItemsListItem.build(domain: "Pocket", isPending: true)
        let presenter = ItemsListItemPresenter(item: item)

        let style = presenter.attributedDetail.attributes(at: 0, effectiveRange: nil)[.style] as! Style
        XCTAssertEqual(UIColor(style.colorAsset), UIColor(.ui.grey5))
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let pendingTitle: Style = title.with(color: .ui.grey5)

    static let detail: Style = .header.sansSerif.p4
        .with(color: .ui.grey4)
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let pendingDetail: Style = .detail.with(color: .ui.grey5)
}
