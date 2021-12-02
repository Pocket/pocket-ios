import UIKit
import SwiftUI


class SignInCoordinator {
    let viewController: UIViewController

    init(model: SignInViewModel) {
        viewController = UIHostingController(
            rootView: SignInView(model: model)
        )
    }
}
