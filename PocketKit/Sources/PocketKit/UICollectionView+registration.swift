import UIKit


extension UICollectionView {
    func register<T: UICollectionViewCell>(cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: "\(T.self)")
    }

    func register<T: UICollectionReusableView>(
        viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) {
        register(
            viewClass,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: "\(T.self)"
        )
    }

    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath)

        guard let typedCell = cell as? T else {
            fatalError("Unable to cast cell of type \(type(of: cell)) to expected type \(T.self)")
        }

        return typedCell
    }

    func dequeueReusableView<T: UICollectionReusableView>(forSupplementaryViewOfKind kind: String, for indexPath: IndexPath) -> T {
        let supplementaryView = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        )

        guard let typedSupplementaryView = supplementaryView as? T else {
            fatalError("Unable to cast supplementary view of type \(type(of: supplementaryView)) to expected type \(T.self)")
        }

        return typedSupplementaryView
    }
}
