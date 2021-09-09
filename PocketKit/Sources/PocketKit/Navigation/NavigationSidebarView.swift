import SwiftUI
import Textile


struct NavigationSidebarView: View {

    @ObservedObject
    private var model: MainViewModel

    init(model: MainViewModel) {
        self.model = model
    }

    var body: some View {
        List(MainViewModel.AppSection.allCases) { section in
            Button {
                model.selectedSection = section
            } label: {
                Text(section.navigationTitle)
            }
        }
        .listStyle(.sidebar)
        .accessibilityIdentifier("navigation-sidebar")
    }
}
