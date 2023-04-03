import SwiftUI
import Textile
import L10n

struct OverflowMenu: View {
    @EnvironmentObject
    var viewModel: PocketItemViewModel
    @State private var showingAlert = false
    @State private var showingSheet = false

    var body: some View {
        Menu {
            Button(action: {
                showingSheet = true
            }) {
                Label {
                    Text(L10n.addTags)
                } icon: {
                    Image(asset: .tag)
                }
            }.accessibilityIdentifier("item-action-add-tags")

            if viewModel.isArchived {
                MoveToSavesButton()
                    .environmentObject(viewModel)
            } else {
                ArchiveButton()
                    .environmentObject(viewModel)
            }

            Button(action: {
                showingAlert = true
            }) {
                Label {
                    Text(L10n.delete)
                } icon: {
                    Image(asset: .delete)
                }
            }.accessibilityIdentifier("item-action-delete")
        } label: {
            Image(asset: .overflow)
                .actionButtonStyle(selected: false)
        }
        .alert(L10n.areYouSureYouWantToDeleteThisItem, isPresented: $showingAlert) {
            Button(L10n.no, role: .cancel) { }
            Button(L10n.yes, role: .destructive) {
                withAnimation {
                    viewModel.delete()
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            if let viewModel = viewModel.tagsViewModel {
                AddTagsView(viewModel: viewModel)
                    .onDisappear {}
            }
        }
        .onTapGesture {
            viewModel.trackOverflowMenu()
        }
        .accessibilityIdentifier("overflow-menu")
    }
}

struct ArchiveButton: View {
    @EnvironmentObject
    var viewModel: PocketItemViewModel
    var body: some View {
        Button(action: {
            withAnimation {
                viewModel.archive()
            }
        }) {
            Label {
                Text(L10n.archive)
            } icon: {
                Image(asset: .archive)
            }
        }.accessibilityIdentifier("item-action-archive")
    }
}

struct MoveToSavesButton: View {
    @EnvironmentObject
    var viewModel: PocketItemViewModel
    var body: some View {
        Button(action: {
            withAnimation {
                viewModel.moveToSaves()
            }
        }) {
            Label {
                Text(L10n.moveToSaves)
            } icon: {
                Image(asset: .save)
            }
        }.accessibilityIdentifier("item-action-move-to-saves")
    }
}
