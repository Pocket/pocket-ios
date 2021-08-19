// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit


class KeychainAccessTokenStoreTests: XCTestCase {
    var mockKeychain: MockKeychain!

    override func setUp() {
        mockKeychain = MockKeychain()
    }

    func test_save_callsAddItem() throws {
        let store = KeychainAccessTokenStore(keychain: mockKeychain)
        try store.save(token: "the-token")

        XCTAssertTrue(mockKeychain.addCalls.wasCalled)
        XCTAssertEqual(
            mockKeychain.addCalls.last?.query,
            [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: Bundle.main.bundleIdentifier!,
                kSecValueData as String: "the-token".data(using: .utf8)!
            ] as CFDictionary
        )
    }

    func test_save_whenAddItemFails_throwsAnError() {
        mockKeychain.addReturnVal = 1
        let store = KeychainAccessTokenStore(keychain: mockKeychain)

        XCTAssertThrowsError(try store.save(token: "the-token"))
    }

    func test_accessToken_callsCopyMatching() {
        let store = KeychainAccessTokenStore(keychain: mockKeychain)
        _ = store.accessToken

        XCTAssertTrue(mockKeychain.copyMatchingCalls.wasCalled)
        XCTAssertEqual(
            mockKeychain.copyMatchingCalls.last?.query,
            [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: Bundle.main.bundleIdentifier!,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnData as String: true
            ] as CFDictionary
        )
    }

    func test_accessToken_cachesValueFromKeychain() throws {
        let store = KeychainAccessTokenStore(keychain: mockKeychain)
        mockKeychain.copyMatchingResult = "the-token".data(using: .utf8) as CFTypeRef
        mockKeychain.deleteReturnVal = 0

        _ = store.accessToken // fetch from keychain
        _ = store.accessToken // use in-memory cache

        XCTAssertEqual(mockKeychain.copyMatchingCalls.count, 1)

        try store.save(token: "new-token")
        mockKeychain.copyMatchingResult = "new-token".data(using: .utf8) as CFTypeRef
        XCTAssertEqual(store.accessToken, "new-token")
        XCTAssertEqual(store.accessToken, "new-token")
        XCTAssertEqual(mockKeychain.copyMatchingCalls.count, 2)

        try store.delete()
        mockKeychain.copyMatchingResult = nil
        XCTAssertEqual(store.accessToken, nil)
        XCTAssertEqual(mockKeychain.copyMatchingCalls.count, 3)

        mockKeychain.copyMatchingResult = "even-newer-token".data(using: .utf8) as CFTypeRef
        XCTAssertEqual(store.accessToken, "even-newer-token")
        XCTAssertEqual(mockKeychain.copyMatchingCalls.count, 4)
    }

    func test_accessToken_whenCopyMatchingSucceeds_returnsDecodedToken() {
        mockKeychain.copyMatchingResult = "the-token".data(using: .utf8) as CFTypeRef
        let store = KeychainAccessTokenStore(keychain: mockKeychain)

        XCTAssertEqual(store.accessToken, "the-token")
    }

    func test_accessToken_whenCopyMatchingFails_returnsNil() {
        mockKeychain.copyMatchingReturnVal = 1
        let store = KeychainAccessTokenStore(keychain: mockKeychain)

        XCTAssertEqual(store.accessToken, nil)
    }

    func test_delete_callsDelete() throws {
        let store = KeychainAccessTokenStore(keychain: mockKeychain)
        try store.delete()

        XCTAssertTrue(mockKeychain.deleteCalls.wasCalled)
        XCTAssertEqual(
            mockKeychain.deleteCalls.last?.query,
            [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: Bundle.main.bundleIdentifier!
            ] as CFDictionary
        )
    }

    func test_delete_whenDeleteFails_throwsAnError() {
        mockKeychain.deleteReturnVal = 1
        let store = KeychainAccessTokenStore(keychain: mockKeychain)

        XCTAssertThrowsError(try store.delete())
    }
}
