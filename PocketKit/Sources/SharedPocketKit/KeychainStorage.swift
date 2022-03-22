import Foundation
import Combine


@propertyWrapper
public class KeychainStorage<T: Codable> {
    private let keychain: Keychain
    private let service: String
    private let account: String
    private let accessGroup: String

    private var subject: CurrentValueSubject<T?, Never>!

    public var wrappedValue: T? {
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

    public var projectedValue: AnyPublisher<T?, Never> {
        subject.eraseToAnyPublisher()
    }

    init(
        keychain: Keychain = SecItemKeychain(),
        service: String = "pocket",
        account: String,
        accessGroup: String = "group.com.mozilla.pocket"
    ) {
        self.keychain = keychain
        self.service = service
        self.account = account
        self.accessGroup = accessGroup

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

        let query = makeQuery([
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ])

        let status = keychain.add(query: query as CFDictionary, result: nil)
        return status == errSecSuccess ? value : nil
    }

    private func update(value: T?) -> T? {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return nil
        }

        let status = keychain.update(
            query: makeQuery(),
            attributes: [kSecValueData: data] as CFDictionary
        )

        return status == errSecSuccess ? value : nil
    }

    private func read() -> T? {
        let query = makeQuery([kSecReturnData: true])

        var result: AnyObject?
        let status = keychain.copyMatching(query: query, result: &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return decoded
    }

    private func delete() {
        _ = keychain.delete(query: makeQuery())
        subject.value = nil
    }

    private func makeQuery(_ additionalProperties: [CFString: Any] = [:]) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: accessGroup
        ].merging(additionalProperties) { _, new in new } as CFDictionary
    }
}
