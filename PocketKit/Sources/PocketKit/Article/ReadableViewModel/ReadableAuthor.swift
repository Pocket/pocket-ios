import Sync


protocol ReadableAuthor {
    var name: String? { get }
}

extension Author: ReadableAuthor { }
