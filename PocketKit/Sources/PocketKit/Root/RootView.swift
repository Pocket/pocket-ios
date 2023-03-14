import SwiftUI

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init() {
        self.model = RootViewModel()
    }

    public var body: some View {
        if model.isLoggedIn {
            MainView(model: MainViewModel())
        } else {
            LoggedOutViewControllerSwiftUI(model: LoggedOutViewModel())
        }
    }
}
