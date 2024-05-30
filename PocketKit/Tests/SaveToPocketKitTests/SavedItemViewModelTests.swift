// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Analytics
import SharedPocketKit
import Combine

@testable import Sync
@testable import SaveToPocketKit

class SavedItemViewModelTests: XCTestCase {
    class MockRecentSavesWidgetStore: ItemWidgetsStore {
        var topics: [SharedPocketKit.ItemContentContainer] = []
        var kind: Sync.ItemWidgetKind = .unknown
        func updateTopics(_ topics: [SharedPocketKit.ItemContentContainer]) throws { }
    }

    private var appSession: AppSession!
    private var saveService: MockSaveService!
    private var dismissTimer: Timer.TimerPublisher!
    private var tracker: MockTracker!
    private var userDefaults: UserDefaults!
    private var user: MockUser!
    private var consumerKey: String!
    private var space: Space!
    private var notificationCenter: NotificationCenter!
    private var subscriptions: Set<AnyCancellable> = []

    private func subject(
        appSession: AppSession? = nil,
        saveService: SaveService? = nil,
        dismissTimer: Timer.TimerPublisher? = nil,
        tracker: Tracker? = nil,
        consumerKey: String? = nil,
        userDefaults: UserDefaults? = nil,
        user: User? = nil,
        notificationCenter: NotificationCenter? = nil
    ) -> SavedItemViewModel {
        SavedItemViewModel(
            appSession: appSession ?? self.appSession,
            saveService: saveService ?? self.saveService,
            dismissTimer: dismissTimer ?? self.dismissTimer,
            tracker: tracker ?? self.tracker,
            consumerKey: consumerKey ?? self.consumerKey,
            userDefaults: userDefaults ?? self.userDefaults,
            user: user ?? self.user,
            notificationCenter: notificationCenter ?? self.notificationCenter,
            recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService(store: MockRecentSavesWidgetStore())
        )
    }

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false

        appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
        saveService = MockSaveService()
        dismissTimer = Timer.TimerPublisher(interval: 0, runLoop: .main, mode: .default)
        tracker = MockTracker()
        consumerKey = "test-key"
        space = .testSpace()
        userDefaults = UserDefaults(suiteName: "SavedItemViewModelTests")
        user = MockUser()
        notificationCenter = .default

        let savedItem = SavedItem(context: space.backgroundContext, url: "http://mozilla.com")
        saveService.stubSave { _ in .newItem(savedItem) }
    }

    override func tearDownWithError() throws {
        subscriptions = []

        UserDefaults.standard.removePersistentDomain(forName: "SavedItemViewModelTests")
        try space.clear()
        try super.tearDownWithError()
    }
}

// MARK: - Session, no URL
extension SavedItemViewModelTests {
    func test_save_ifValidSessionAndNoURL_doesNotCallSave() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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
        await fulfillment(of: [completeRequestExpectation], timeout: 2)
    }
}

// MARK: - Session, URL
extension SavedItemViewModelTests {
    func test_save_ifValidSessionAndURL_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, "https://getpocket.com")
    }

    func test_save_ifValidSessionAndURLString_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, "https://getpocket.com")
    }

    /// This test imitates how a specific PDF URL (https://arxiv.org/pdf/2306.00739.pdf) was ingested by the app from the Share extension
    func test_save_ifValidSessionAndPDF() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let provider1 = MockItemProvider()
        provider1.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "com.adobe.pdf"
        }
        provider1.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com/pdf/some.name.pdf")! as NSSecureCoding
        }

        let provider2 = MockItemProvider()
        provider2.stubHasItemConformingToTypeIdentifier { identifier in
            return identifier == "public.url"
        }
        provider2.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com/pdf/some.name.pdf")! as NSSecureCoding
        }

        let extensionItem1 = MockExtensionItem(itemProviders: [provider1])
        let extensionItem2 = MockExtensionItem(itemProviders: [provider2])

        let context = MockExtensionContext(extensionItems: [extensionItem1, extensionItem2])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, "https://getpocket.com/pdf/some.name.pdf")
    }

    func test_save_withStringContainingURL_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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
            "Get Pocket https://getpocket.com" as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertEqual(saveService.saveCall(at: 0)?.url, "https://getpocket.com")
    }

    func test_save_ifValidSessionAndURL_automaticallyCompletesRequest() async {
        let appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
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

        await fulfillment(of: [completeRequestExpectation], timeout: 2)
    }

    func test_save_whenResavingExistingItem_updatesInfoViewModel() async {
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let savedItem = SavedItem(context: self.space.backgroundContext, url: "http://mozilla.com")
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
        await fulfillment(of: [infoViewModelChanged], timeout: 2)
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
        await fulfillment(of: [infoViewModelChanged], timeout: 2)
        subscription.cancel()
    }
}

// MARK: - Tags
extension SavedItemViewModelTests {
    func test_tagsActionTitle_withNoItem_isAddTags() throws {
        let viewModel = subject()
        let hasCorrectTitle = viewModel.tagsActionAttributedText.string == "Add tags"
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_tagsActionTitle_withNoTags_isAddTags() throws {
        let savedItem = space.buildSavedItem(tags: [])

        let viewModel = subject()
        viewModel.savedItem = savedItem
        let hasCorrectTitle = viewModel.tagsActionAttributedText.string == "Add tags"
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_tagsActionTitle_withTags_isEditTags() throws {
        let savedItem = space.buildSavedItem(tags: ["tag 1"])

        let viewModel = subject()
        viewModel.savedItem = savedItem
        let hasCorrectTitle = viewModel.tagsActionAttributedText.string == "Edit tags"
        XCTAssertTrue(hasCorrectTitle)
    }

    @MainActor 
    func test_addTagsAction_sendsAddTagsViewModel() {
        let viewModel = subject()
        saveService.stubRetrieveTags { _ in return nil }
        let expectAddTags = expectation(description: "expect add tags to present")
        let subscription = viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            defer { expectAddTags.fulfill() }
            XCTAssertNotNil(viewModel)
        }

        let extensionItem = MockExtensionItem(itemProviders: [])
        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        viewModel.showAddTagsView(from: context)

        wait(for: [expectAddTags], timeout: 2)
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
            do { infoViewModelChanged.fulfill() }
        }

        await fulfillment(of: [infoViewModelChanged], timeout: 2)
        subscription.cancel()
    }

    func test_retrieveTags_updatesInfoViewModel() async {
        let viewModel = subject()
        saveService.stubRetrieveTags { _ in
            let tag: Tag = Tag(context: self.space.backgroundContext)
            tag.name = "tag 1"
            tag.remoteID = tag.name.uppercased()
            return [tag]
        }
        let tags = viewModel.retrieveTags(excluding: [])
        XCTAssertEqual(tags?.count, 1)
        XCTAssertEqual(tags?[0].name, "tag 1")
    }
}
