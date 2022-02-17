import XCTest
@testable import PocketKit


class KeychainStorageTests: XCTestCase {
    struct Test: Codable {
        let value: String
    }

    func test_get_callsCopyMatching() {
        let keychain = MockKeychain()
        let service = "MockService"
        let account = "MockAccount"
        let storage = KeychainStorage<Test?>(keychain: keychain, service: service, account: account)

        _ = storage.wrappedValue

        // One read on init, one read if the current cached value is nil
        XCTAssertEqual(keychain.copyMatchingCalls.count, 2)
    }

    func test_set_whenInitialValue_callsAdd() {
        let keychain = MockKeychain()
        let service = "MockService"
        let account = "MockAccount"
        let storage = KeychainStorage<Test>(keychain: keychain, service: service, account: account)

        storage.wrappedValue = Test(value: "test")

        XCTAssertEqual(keychain.addCalls.count, 1)
    }

    func test_set_whenValueExists_callsUpdate() {
        let keychain = MockKeychain()
        let service = "MockService"
        let account = "MockAccount"
        let storage = KeychainStorage<Test>(keychain: keychain, service: service, account: account)

        let initialValue = Test(value: "test")
        storage.wrappedValue = initialValue
        keychain.copyMatchingResult = try! JSONEncoder().encode(initialValue) as CFTypeRef
        storage.wrappedValue = Test(value: "test-2")

        XCTAssertEqual(keychain.addCalls.count, 1)
        XCTAssertEqual(keychain.updateCalls.count, 1)
    }

    func test_set_whenNil_callsDelete() {
        let keychain = MockKeychain()
        let service = "MockService"
        let account = "MockAccount"
        let storage = KeychainStorage<Test>(keychain: keychain, service: service, account: account)

        storage.wrappedValue = nil

        XCTAssertEqual(keychain.deleteCalls.count, 1)
    }

    func test_read_usesCachedValue() {
        let keychain = MockKeychain()
        let service = "MockService"
        let account = "MockAccount"
        let storage = KeychainStorage<Test>(keychain: keychain, service: service, account: account)

        // One read on init, one read if the current cached value is nil
        _ = storage.wrappedValue
        XCTAssertEqual(keychain.copyMatchingCalls.count, 2)

        let value = Test(value: "test")
        storage.wrappedValue = value
        keychain.copyMatchingResult = try! JSONEncoder().encode(value) as CFTypeRef

        _ = storage.wrappedValue
        _ = storage.wrappedValue
        _ = storage.wrappedValue

        // The cached value is preferred over the keychain, so we shouldn't see another read unless we delete
        XCTAssertEqual(keychain.copyMatchingCalls.count, 2)

        storage.wrappedValue = nil
        _ = storage.wrappedValue
        XCTAssertEqual(keychain.copyMatchingCalls.count, 3)
    }
}
