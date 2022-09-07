import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: "\(T.self)")
    }

    func register<T: UIView>(headerFooterView: T.Type) {
        register(headerFooterView.self, forHeaderFooterViewReuseIdentifier: "\(headerFooterView.self)")
    }

    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath)

        guard let typedCell = cell as? T else {
            fatalError("Unable to cast cell of type \(type(of: cell)) to expected type \(T.self)")
        }

        return typedCell
    }

    func dequeueReusableHeaderFooterView<T: UIView>() -> T {
        let supplementaryView = dequeueReusableHeaderFooterView(withIdentifier: "\(T.self)")

        guard let typedSupplementaryView = supplementaryView as? T else {
            fatalError("Unable to cast supplementary view of type \(type(of: supplementaryView)) to expected type \(T.self)")
        }

        return typedSupplementaryView
    }
}
