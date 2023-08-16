// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public extension UIView {
    /// Creates a UIView instance with a SwiftUI view embedded in it
    /// - Parameter view: the original SwiftUI view
    /// - Returns: the UIView instance
    class func embedSwiftUIView<Content: View>(_ view: Content) -> UIView {
        let controller = UIHostingController(rootView: view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .clear
        return controller.view
    }

    /// Add top, bottom, leading and trailing constraints between a view and a subview
    /// - Parameters:
    ///   - subview: the subview.
    ///   - insets: optional edge insets.
    func pinSubviewToAllEdges(_ subview: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: -insets.left),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
            topAnchor.constraint(equalTo: subview.topAnchor, constant: -insets.top),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom),
        ])
    }
}
