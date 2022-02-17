import Foundation
struct Session: Codable {
    let guid: String
    let accessToken: String
    let userIdentifier: String
}

@propertyWrapper
struct KeychainStorage<T: Codable> {
    private let keychain: Keychain

    private var value: T?
    private let service: String
    private let account: String

    var wrappedValue: T? {
        get {
            read()
        }
        set {
            if let newValue = newValue {
                upsert(value: newValue)
            } else {
                delete()
            }
        }
    }

    init(keychain: Keychain, service: String, account: String) {
        self.keychain = keychain
        self.service = service
        self.account = account
    }

    private func upsert(value: T?) {
        if read() == nil {
            add(value: value)
        } else {
            update(value: value)
        }
    }

    private func add(value: T?) {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]

        _ = keychain.add(query: query as CFDictionary, result: nil)
    }

    private func update(value: T?) {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data
        ]

        _ = keychain.update(query: query as CFDictionary, attributes: attributes as CFDictionary)
    }

    private func read() -> T? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ]

        var result: AnyObject?
        _ = keychain.copyMatching(query: query as CFDictionary, result: &result)
        guard let data = result as? Data, let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return decoded
    }

    private func delete() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        _ = keychain.delete(query: query as CFDictionary)
    }
}
