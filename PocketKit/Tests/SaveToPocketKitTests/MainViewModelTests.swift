import XCTest
@testable import SaveToPocketKit


class MainViewModelTests: XCTestCase {
    private var saveService: MockSaveService!

    private func subject(saveService: SaveService? = nil) -> MainViewModel {
        MainViewModel(saveService: saveService ?? self.saveService)
    }

    override func setUp() {
        saveService = MockSaveService()
        saveService.stubSave { _ in }
    }

    func test_save_sendsCorrectURLToService() async {
        let provider = MockItemProvider()

        provider.stubHasItemConformingToTypeIdentifier { _ in
            return true
        }

        provider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])
        let context = MockExtensionContext(extensionItems: [extensionItem])

        let viewModel = subject()
        await viewModel.save(from: context)
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, URL(string: "https://getpocket.com")!)
    }
}
