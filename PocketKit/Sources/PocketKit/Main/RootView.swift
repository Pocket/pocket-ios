import SwiftUI

public struct RootView: View {
    @ObservedObject var model: RootViewModel

    public init(model: RootViewModel) {
        self.model = model
    }

    public var body: some View {
        if let model = model.mainViewModel {
            mainView(model: model)
        }

        if let model = model.loggedOutViewModel {
            loggedOutView(model: model)
        }
    }

    private func mainView(model: MainViewModel) -> MainView {
        MainView(model: model)
    }

    private func loggedOutView(model: LoggedOutViewModel) -> LoggedOutViewControllerSwiftUI {
       LoggedOutViewControllerSwiftUI(model: model)
    }
}
