import UIKit


extension UICollectionView {
    func register(cellClass: AnyClass) {
        register(cellClass, forCellWithReuseIdentifier: "\(cellClass)")
    }

    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath)

        guard let typedCell = cell as? T else {
            fatalError("Unable to cast cell of type \(type(of: cell)) to expected type \(T.self)")
        }

        return typedCell
    }
}
