// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.


import SwiftUI
import Kingfisher

private enum Constants {
    static let cornerRadius: CGFloat = 4
    static let thumbnailSize = CGSize(width: 90, height: 60)
}

private extension Style {
    static let title: Style = .header.sansSerif.h7
    static let detail: Style = .header.sansSerif.p4.with(color: .ui.grey4)
}

public protocol ItemRow: ObservableObject {
    var index: Int { get }
    var title: String { get }
    var detail: String { get }
    var thumbnailURL: URL? { get }
    var isFavorite: Bool { get }
    var activityItems: [Any] { get }

    func favorite()
    func unfavorite()
    func archive()
    func delete()
}

public struct ItemRowView<Model: ItemRow>: View {
    private var model: Model

    @State
    private var isShareSheetPresented = false

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.title)
                        .style(.title)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(model.detail)
                        .style(.detail)
                        .lineLimit(1)
                }

                if let thumbnailURL = model.thumbnailURL {
                    Spacer()

                    KFImage(thumbnailURL)
                        .placeholder {
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(width: Constants.thumbnailSize.width, height: Constants.thumbnailSize.height)
                        }
                        .scaleFactor(UIScreen.main.scale)
                        .setProcessor(ResizingImageProcessor(referenceSize: Constants.thumbnailSize, mode: .aspectFill))
                        .appendProcessor(CroppingImageProcessor(size: Constants.thumbnailSize))
                        .cornerRadius(Constants.cornerRadius)
                }
            }

            HStack {
                if model.isFavorite {
                    Image(systemName: "star.fill")
                        .accessibilityIdentifier("favorite")
                        .foregroundColor(Color(.branding.amber3))
                }

                Spacer()

                Menu {
                    favoriteButton()

                    Button {
                        model.archive()
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }

                    Button {
                        model.delete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        isShareSheetPresented.toggle()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                }.foregroundColor(Color(.ui.grey3))
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $isShareSheetPresented) {
            ActivitySheet(activityItems: model.activityItems)
        }
    }

    @ViewBuilder
    private func favoriteButton() -> some View {
        if model.isFavorite {
            Button {
                model.unfavorite()
            } label: {
                Label("Unfavorite", systemImage: "star.slash")
            }
        } else {
            Button {
                model.favorite()
            } label: {
                Label("Favorite", systemImage: "star")
            }
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    class DummyModel: ItemRow, Identifiable {
        var index = 0
        
        var id = "hi"
        
        var title: String = """
        Cum sociis natoque penatibus et magnis dis parturient montes,
        nascetur ridiculus mus. Donec sed odio dui.
        """
        
        var detail: String = "Etiam Sem Magna Parturient Bibendum • 5 min"
        var thumbnailURL: URL? = URL(string: "http://placekitten.com/200/300")!
        var isFavorite: Bool = false
        var activityItems: [Any] = []

        func favorite() {}
        func unfavorite() {}
        func archive() {}
        func delete() {}
    }

    static var previews: some View {
        Group {
            List([DummyModel()], rowContent: ItemRowView.init)
                .preferredColorScheme(.dark)
            List([DummyModel()], rowContent: ItemRowView.init)
        }
    }
}
