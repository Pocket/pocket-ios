import XCTest
import Analytics
import SharedPocketKit
import Sync

@testable import Sync
@testable import SaveToPocketKit

class SavedItemViewModelTests: XCTestCase {
    private var appSession: AppSession!
    private var saveService: MockSaveService!
    private var dismissTimer: Timer.TimerPublisher!
    private var tracker: MockTracker!
    private var consumerKey: String!
    private var space: Space!

    private func subject(
        appSession: AppSession? = nil,
        saveService: SaveService? = nil,
        dismissTimer: Timer.TimerPublisher? = nil,
        tracker: Tracker? = nil,
        consumerKey: String? = nil
    ) -> SavedItemViewModel {
        SavedItemViewModel(
            appSession: appSession ?? self.appSession,
            saveService: saveService ?? self.saveService,
            dismissTimer: dismissTimer ?? self.dismissTimer,
            tracker: tracker ?? self.tracker,
            consumerKey: consumerKey ?? self.consumerKey
        )
    }

    override func setUp() {
        self.continueAfterFailure = false

        appSession = AppSession(keychain: MockKeychain())
        saveService = MockSaveService()
        dismissTimer = Timer.TimerPublisher(interval: 0, runLoop: .main, mode: .default)
        tracker = MockTracker()
        consumerKey = "test-key"
        space = .testSpace()

        let savedItem = SavedItem()
        saveService.stubSave { _ in .newItem(savedItem) }
    }

    override func tearDown() async throws {
        try space.clear()
    }
}

// MARK: - Session, no URL
extension SavedItemViewModelTests {
    func test_save_ifValidSessionAndNoURL_doesNotCallSave() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let extensionItem = MockExtensionItem(itemProviders: [])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertNil(saveService.saveCall(at: 0))
    }

    func test_save_ifValidSessionAndNoURL_doesNotAutomaticallyCompleteRequest() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let extensionItem = MockExtensionItem(itemProviders: [])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")
        completeRequestExpectation.isInverted = true
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        await viewModel.save(from: context)
        wait(for: [completeRequestExpectation], timeout: 1)
    }
}

// MARK: - Session, URL
extension SavedItemViewModelTests {
    func test_save_ifValidSessionAndURL_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )

        let viewModel = subject(appSession: appSession)

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "public.url"
        }
        provider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, URL(string: "https://getpocket.com")!)
    }

    func test_save_ifValidSessionAndURLString_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "public.plain-text"
        }
        provider.stubLoadItem { _, _ in
            "https://getpocket.com" as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, URL(string: "https://getpocket.com")!)
    }

    func test_save_ifValidSessionAndURL_automaticallyCompletesRequest() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )

        let viewModel = subject(appSession: appSession)

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "public.url"
        }
        provider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        await viewModel.save(from: context)

        wait(for: [completeRequestExpectation], timeout: 1)
    }

    func test_save_whenResavingExistingItem_updatesInfoViewModel() async {
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let savedItem = SavedItem()
        saveService.stubSave { _ in .existingItem(savedItem) }

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "public.url"
        }
        provider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        let viewModel = subject()

        let infoViewModelChanged = expectation(description: "infoViewModelChanged")
        let subscription = viewModel.$infoViewModel.dropFirst().sink { model in
            defer { infoViewModelChanged.fulfill() }
            XCTAssertEqual(model.attributedText.string, "Saved to Pocket")
            XCTAssertEqual(model.attributedDetailText?.string, "You've already saved this. We'll move it to the top of your list.")
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])
        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        wait(for: [infoViewModelChanged], timeout: 1)
        subscription.cancel()
    }

    func test_save_onError_updatesInfoViewModel() async {
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { identifier in
            return false
        }

        let viewModel = subject()

        let infoViewModelChanged = expectation(description: "infoViewModelChanged")
        let subscription = viewModel.$infoViewModel.dropFirst().sink { model in
            defer { infoViewModelChanged.fulfill() }
            XCTAssertEqual(model.attributedText.string, "Pocket couldn't save this link")
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])
        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        wait(for: [infoViewModelChanged], timeout: 1)
        subscription.cancel()
    }
}

// MARK: - Tags
extension SavedItemViewModelTests {
    func test_addTagsAction_sendsAddTagsViewModel() {
        let viewModel = subject()

        let expectAddTags = expectation(description: "expect add tags to present")
        let subscription = viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            defer { expectAddTags.fulfill() }
            XCTAssertNotNil(viewModel)
        }

        let extensionItem = MockExtensionItem(itemProviders: [])
        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        viewModel.showAddTagsView(from: context)

        wait(for: [expectAddTags], timeout: 1)
        subscription.cancel()
    }

    func test_addTags_updatesInfoViewModel() async {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject()
        viewModel.savedItem = item
        saveService.stubAddTags { _, _  in
            return .taggedItem(item)
        }

        let extensionItem = MockExtensionItem(itemProviders: [])
        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        viewModel.addTags(tags: ["tag 1"], from: context)
        let infoViewModelChanged = expectation(description: "infoViewModelChanged")
        let subscription = viewModel.$infoViewModel.sink { model in
            defer { infoViewModelChanged.fulfill() }
            XCTAssertEqual(model.attributedText.string, "Tags Added!")
        }

        wait(for: [infoViewModelChanged], timeout: 1)
        subscription.cancel()
    }

    func test_retrieveTags_updatesInfoViewModel() async {
        let viewModel = subject()
        saveService.stubRetrieveTags { _ in
            let tag: Tag = self.space.new()
            tag.name = "tag 1"
            return [tag]
        }
        let tags = viewModel.retrieveTags(excluding: [])
        XCTAssertEqual(tags?.count, 1)
        XCTAssertEqual(tags?[0].name, "tag 1")
    }
}
