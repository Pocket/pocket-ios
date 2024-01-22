// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization
import SharedPocketKit

struct OverflowMenu: View {
    @EnvironmentObject var viewModel: PocketItemViewModel
    @State private var showingAlert = false
    @State private var showingSheet = false

    var body: some View {
        Menu {
            Button(action: {
                showingSheet = true
            }) {
                Label {
                    if viewModel.hasTags {
                        Text(Localization.ItemAction.editTags)
                    } else {
                        Text(Localization.ItemAction.addTags)
                    }
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
                    Text(Localization.delete)
                } icon: {
                    Image(asset: .delete)
                }
            }.accessibilityIdentifier("item-action-delete")
        } label: {
            Image(asset: .overflow)
                .actionButtonStyle(selected: false)
        }
        .alert(Localization.areYouSureYouWantToDeleteThisItem, isPresented: $showingAlert) {
            Button(Localization.no, role: .cancel) { }
            Button(Localization.yes, role: .destructive) {
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
            Haptics.defaultTap()
            viewModel.trackOverflowMenu()
        }
        .accessibilityIdentifier("overflow-menu")
    }
}

struct ArchiveButton: View {
    @EnvironmentObject var viewModel: PocketItemViewModel
    var body: some View {
        Button(action: {
            withAnimation {
                viewModel.archive()
            }
        }) {
            Label {
                Text(Localization.archive)
            } icon: {
                Image(asset: .archive)
            }
        }.accessibilityIdentifier("item-action-archive")
    }
}

struct MoveToSavesButton: View {
    @EnvironmentObject var viewModel: PocketItemViewModel
    var body: some View {
        Button(action: {
            withAnimation {
                viewModel.moveToSaves()
            }
        }) {
            Label {
                Text(Localization.Item.OverflowMenu.moveToSaves)
            } icon: {
                Image(asset: .save)
            }
        }.accessibilityIdentifier("item-action-move-to-saves")
    }
}
