import UIKit

public extension UIImage {
    func addImagePadding(width: CGFloat, height: CGFloat) -> UIImage? {
        let maxWidth: CGFloat = size.width + width
        let maxHeight: CGFloat = size.height + height
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), false, 0)
        let origin: CGPoint = CGPoint(x: (maxWidth - size.width) / 2, y: (maxHeight - size.height) / 2)
        draw(at: origin)
        let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithPadding
    }
}
