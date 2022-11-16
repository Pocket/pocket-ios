import Foundation
import Sync

class MockSaveService: SaveService {
    private var calls: [String: [Any]] = [:]
    private var implementations: [String: Any] = [:]
}

extension MockSaveService {
    private static let saveImpl = "CallImpl"
    typealias SaveImpl = (URL) -> Sync.SaveServiceStatus

    struct SaveCall {
        let url: URL
    }

    func stubSave(_ impl: @escaping SaveImpl) {
        implementations[Self.saveImpl] = impl
    }

    func saveCall(at index: Int) -> SaveCall? {
        calls[Self.saveImpl]?[index] as? SaveCall
    }

    func save(url: URL) -> Sync.SaveServiceStatus {
        guard let impl = implementations[Self.saveImpl] as? SaveImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.saveImpl] = (calls[Self.saveImpl] ?? []) + [SaveCall(url: url)]
        return impl(url)
    }
}

// MARK: - Retrieve Tags
extension MockSaveService {
    private static let retrieveTags = "retrieveTags"
    typealias RetrieveTagsImpl = ([String]) -> [Tag]?

    struct RetrieveTagsImplCall {
        let tags: [String]
    }

    func stubRetrieveTags(impl: @escaping RetrieveTagsImpl) {
        implementations[Self.retrieveTags] = impl
    }

    func retrieveTags(excluding tags: [String]) -> [Tag]? {
        guard let impl = implementations[Self.retrieveTags] as? RetrieveTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.retrieveTags] = (calls[Self.retrieveTags] ?? []) + [
            RetrieveTagsImplCall(tags: tags)
        ]

        return impl(tags)
    }

    func retrieveTagsCall(at index: Int) -> RetrieveTagsImplCall? {
        guard let calls = calls[Self.retrieveTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? RetrieveTagsImplCall
    }
}

// MARK: - Add Tags
extension MockSaveService {
    private static let addTags = "addTags"
    typealias AddTagsImpl = (SavedItem, [String]?) -> SaveServiceStatus

    struct AddTagsImplCall {
        let savedItem: SavedItem
        let tags: [String]?
    }

    func stubAddTags(impl: @escaping AddTagsImpl) {
        implementations[Self.addTags] = impl
    }

    func addTags(savedItem: SavedItem, tags: [String]) -> SaveServiceStatus {
        guard let impl = implementations[Self.addTags] as? AddTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.addTags] = (calls[Self.addTags] ?? []) + [
            AddTagsImplCall(savedItem: savedItem, tags: tags)
        ]

        return impl(savedItem, tags)
    }

    func addTagsCall(at index: Int) -> AddTagsImplCall? {
        guard let calls = calls[Self.addTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? AddTagsImplCall
    }
}
