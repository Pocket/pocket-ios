import Combine
import Sync
import Foundation
import Textile
import UIKit


protocol ReadableAuthor {
    var name: String? { get }
}
extension Author: ReadableAuthor { }
extension UnmanagedItem.Author : ReadableAuthor { }

protocol ReadableViewModelDelegate: AnyObject {
    func readableViewModelDidFavorite(_ readableViewModel: ReadableViewModel)
    func readableViewModelDidUnfavorite(_ readableViewModel: ReadableViewModel)
    func readableViewModelDidArchive(_ readableViewModel: ReadableViewModel)
    func readableViewModelDidDelete(_ readableViewModel: ReadableViewModel)
    func readableViewModelDidSave(_ readableViewModel: ReadableViewModel)
}

protocol ReadableViewModel: AnyObject {
    var delegate: ReadableViewModelDelegate? { get set }
    
    var actions: Published<[ReadableAction]>.Publisher { get }
    
    var components: [ArticleComponent]? { get }
    var textAlignment: TextAlignment { get }
    var title: String? { get }
    var authors: [ReadableAuthor]? { get }
    var domain: String? { get }
    var publishDate: Date? { get }
    var url: URL? { get }
    
    func shareActivity(additionalText: String?) -> PocketItemActivity?
    func delete()
}
