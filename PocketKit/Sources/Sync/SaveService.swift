import Foundation

public enum SaveServiceStatus {
    case existingItem
    case newItem
}

public protocol SaveService {
    func save(url: URL) -> SaveServiceStatus
}
