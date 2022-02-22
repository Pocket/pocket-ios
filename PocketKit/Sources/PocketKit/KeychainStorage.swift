import Foundation
import Combine


@propertyWrapper
class KeychainStorage<T: Codable> {
    private let keychain: Keychain
    private let service: String
    private let account: String

    private var subject: CurrentValueSubject<T?, Never>!

    var wrappedValue: T? {
        get {
            if let value = subject.value {
                return value
            } else {
                subject.value = read()
                return subject.value
            }
        }
        set {
            if let newValue = newValue, let upserted = upsert(value: newValue) {
                subject.value = upserted
            } else {
                delete()
            }
        }
    }

    var projectedValue: AnyPublisher<T?, Never> {
        subject.eraseToAnyPublisher()
    }

    init(keychain: Keychain = SecItemKeychain(), service: String = Bundle.main.bundleIdentifier!, account: String) {
        self.keychain = keychain
        self.service = service
        self.account = account

        subject = CurrentValueSubject(read())
    }

    private func upsert(value: T?) -> T? {
        if subject.value == nil {
            return add(value: value)
        } else {
            return update(value: value)
        }
    }

    private func add(value: T?) -> T? {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return nil
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = keychain.add(query: query as CFDictionary, result: nil)
        return status == errSecSuccess ? value : nil
    }

    private func update(value: T?) -> T? {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return nil
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data
        ]

        let status = keychain.update(query: query as CFDictionary, attributes: attributes as CFDictionary)
        return status == errSecSuccess ? value : nil
    }

    private func read() -> T? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ]

        var result: AnyObject?
        let status = keychain.copyMatching(query: query as CFDictionary, result: &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return decoded
    }

    private func _delete() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        _ = keychain.delete(query: query as CFDictionary)
    }

    private func delete() {
        _delete()
        subject.value = nil
    }
}

