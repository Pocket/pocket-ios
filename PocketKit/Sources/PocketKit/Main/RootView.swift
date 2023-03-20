import SwiftUI

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init(model: RootViewModel) {
        self.model = model
    }

    public var body: some View {
        if model.isLoggedIn {
            MainView(model: model.mainViewModel)
        } else {
            LoggedOutViewControllerSwiftUI(model: model.loggedOutViewModel)
        }
    }
}
