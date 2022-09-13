import UIKit

protocol Pasteboard: AnyObject {
    var url: URL? { get set }
}

extension UIPasteboard: Pasteboard {

}
