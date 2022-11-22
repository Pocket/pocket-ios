import SwiftUI

struct SearchView: View {
    @ObservedObject
    var viewModel: SearchViewModel

    var body: some View {
        if let emptyState = viewModel.emptyState {
            EmptyStateView(viewModel: emptyState)
                .padding(Margins.normal.rawValue)
        }
    }
}
