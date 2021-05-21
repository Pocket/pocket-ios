// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Kingfisher

struct ItemRow: View {
    @ObservedObject
    private var item: Item

    init(item: Item) {
        self.item = item
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title ?? item.url?.absoluteString ?? "Missing Title")
                    .font(.body)
                Text(caption(item))
                    .font(.caption)
            }
            
            if  item.thumbnailURL != nil {
                Spacer()
                
                VStack {
                    KFImage(item.thumbnailURL)
                        .placeholder {
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(width: Constants.thumbnailSize.width, height: Constants.thumbnailSize.height)
                                .cornerRadius(Constants.cornerRadius)
                        }
                        .scaleFactor(UIScreen.main.scale)
                        .setProcessor(ResizingImageProcessor(referenceSize: Constants.thumbnailSize, mode: .aspectFill))
                        .appendProcessor(CroppingImageProcessor(size: Constants.thumbnailSize))
                        .appendProcessor(RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius))
                    Spacer()
                }
            }
        }
    }
    
    private func caption(_ item: Item) -> String {
        var components: [String] = []
        components.append(item.domain ?? "Missing Domain")
        if item.timeToRead > 0 {
            let timeToRead = "\(item.timeToRead) min"
            components.append(timeToRead)
        }
        return components.joined(separator: " • ")
    }
}

extension ItemRow {
    enum Constants {
        static let cornerRadius: CGFloat = 4
        static let thumbnailSize = CGSize(width: 64, height: 64)
    }
}
