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
    var title: String { get }
    var domain: String { get }
    var timeToRead: String? { get }
    var thumbnailURL: URL? { get }
}

public struct ItemRowView<Model: ItemRow>: View {
    private var model: Model

    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(model.title)
                    .style(.title)
                    .lineLimit(3)
                HStack(spacing: 4) {
                    Text(model.domain)
                        .style(.detail)
                        .lineLimit(1)
                    if let timeToRead = model.timeToRead {
                        Text("•").style(.detail)
                        Text(timeToRead).style(.detail)
                    }
                }
                Spacer()
            }.lineSpacing(6)
            
            if let thumbnailURL = model.thumbnailURL {
                Spacer()
                
                VStack {
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
                    Spacer()
                }
            }
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    class DummyModel: ItemRow, Identifiable {
        var id = "hi"

        var title: String = """
        Cum sociis natoque penatibus et magnis dis parturient montes,
        nascetur ridiculus mus. Donec sed odio dui.
        """

        var domain: String = "Etiam Sem Magna Parturient Bibendum"
        var timeToRead: String? = "5 min"
        var thumbnailURL: URL? = URL(string: "http://placekitten.com/200/300")!
    }

    static var previews: some View {
        Group {
            List([DummyModel()], rowContent: ItemRowView.init)
                .preferredColorScheme(.dark)
            List([DummyModel()], rowContent: ItemRowView.init)
        }
    }
}
