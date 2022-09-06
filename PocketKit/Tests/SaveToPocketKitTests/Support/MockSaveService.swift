import Foundation
import Sync

class MockSaveService: SaveService {
    private var calls: [String: [Any]] = [:]
    private var implementations: [String: Any] = [:]
}

extension MockSaveService {
    private static let saveImpl = "CallImpl"
    typealias SaveImpl = (URL) -> SaveServiceStatus

    struct SaveCall {
        let url: URL
    }

    func stubSave(_ impl: @escaping SaveImpl) {
        implementations[Self.saveImpl] = impl
    }

    func saveCall(at index: Int) -> SaveCall? {
        calls[Self.saveImpl]?[index] as? SaveCall
    }

    func save(url: URL) -> SaveServiceStatus {
        guard let impl = implementations[Self.saveImpl] as? SaveImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.saveImpl] = (calls[Self.saveImpl] ?? []) + [SaveCall(url: url)]
        return impl(url)
    }
}
