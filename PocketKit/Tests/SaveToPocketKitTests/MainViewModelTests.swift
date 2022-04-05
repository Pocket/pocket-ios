import XCTest
import SharedPocketKit
import Sync

@testable import SaveToPocketKit


class MainViewModelTests: XCTestCase {
    private var appSession: AppSession!
    private var saveService: MockSaveService!
    private var timer: Timer.TimerPublisher!

    private func subject(
        appSession: AppSession? = nil,
        saveService: SaveService? = nil,
        timer: Timer.TimerPublisher? = nil
    ) -> MainViewModel {
        MainViewModel(
            appSession: appSession ?? self.appSession,
            saveService: saveService ?? self.saveService,
            dismissTimer: timer ?? self.timer
        )
    }

    override func setUp() {
        appSession = AppSession()
        saveService = MockSaveService()
        timer = Timer.TimerPublisher(interval: 0, runLoop: .main, mode: .default)

        saveService.stubSave { _ in }
    }
}

// MARK: - No session
extension MainViewModelTests {
    func test_save_ifNoCurrentSession_doesNotCallSave() async {
        let viewModel = subject()

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { _ in
            return true
        }
        provider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        let extensionItem = MockExtensionItem(itemProviders: [provider])

        let context = MockExtensionContext(extensionItems: [extensionItem])
        context.stubCompleteRequest { _, _ in }

        await viewModel.save(from: context)
        XCTAssertNil(saveService.saveCall(at: 0))
    }

    func test_save_ifNoValidSession_automaticallyCompletesRequest() async {
        let context = MockExtensionContext(extensionItems: [])
        let viewModel = subject()

        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        await viewModel.save(from: context)

        wait(for: [completeRequestExpectation], timeout: 1)
    }
}

// MARK: - Session, no URL
extension MainViewModelTests {
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


    func test_save_ifValidSessionAndNoURL_automaticallyCompletesRequest() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")

        let context = MockExtensionContext(extensionItems: [])
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        await viewModel.save(from: context)

        wait(for: [completeRequestExpectation], timeout: 1)
    }
}

// MARK: - Session, URL
extension MainViewModelTests {
    func test_save_ifValidSessionAndURL_sendsCorrectURLToService() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { _ in
            return true
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

    func test_save_ifValidSessionAndURL_automaticallyCompletesRequest() async {
        let appSession = AppSession(keychain: MockKeychain())
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )
        let viewModel = subject(appSession: appSession)

        let provider = MockItemProvider()
        provider.stubHasItemConformingToTypeIdentifier { _ in
            return true
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
}
