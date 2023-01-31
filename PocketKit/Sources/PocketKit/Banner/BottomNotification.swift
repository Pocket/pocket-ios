import SwiftUI
import Textile
import UIKit

struct BannerModifier: ViewModifier {
    struct BannerData {
        var image: ImageAsset
        var title: String
        var detail: String
    }

    let data: BannerData
    @Binding var show: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if show {
                VStack {
                    HStack {
                        Image(asset: data.image)
                            .resizable()
                            .frame(width: 83, height: 50, alignment: .leading)
                        Spacer(minLength: 10)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(data.title)
                                .style(.title)
                            Text(data.detail)
                                .style(.subtitle)
                        }
                    }
                    .padding(13)
                    .background(Color(.branding.amber5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(.branding.amber3), lineWidth: 1)
                    )
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: show)
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { value in
                        let verticalAmount = value.translation.height
                        if verticalAmount > 0 {
                            withAnimation {
                                self.show = false
                            }
                        }
                    })
            }
        }
    }
}

extension View {
    func banner(data: BannerModifier.BannerData, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}

private extension Style {
    static let title: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
    static let subtitle: Self = .header.sansSerif.p4.with(weight: .regular).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
}
