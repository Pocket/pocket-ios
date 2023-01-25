import SwiftUI
import Textile
import UIKit

struct BannerModifier: ViewModifier {
    struct BannerData {
        var image: ImageAsset
        var title: String
        var detail: String
    }

    @Binding var data: BannerData
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
                            .padding(8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.title)
                                .style(.title)
                            Text(data.detail)
                                .style(.subtitle)
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(8)
                    .background(Color(red: 1, green: 0.984, blue: 0.89))
                    .cornerRadius(8)
                }
                .padding()
                .animation(.easeInOut, value: show)
                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
    func banner(data: Binding<BannerModifier.BannerData>, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}

private extension Style {
    static let title: Self = .header.sansSerif.h4.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
    static let subtitle: Self = .header.sansSerif.p4.with(weight: .regular).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
}
