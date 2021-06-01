// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import UIKit

public struct AttributedStringView: View {
    private let content: NSAttributedString
    private let tappedURL: Binding<URL?>

    @State
    private var height: CGFloat = 0

    public init(content: NSAttributedString, tappedURL: Binding<URL?>) {
        self.content = content
        self.tappedURL = tappedURL
    }

    public var body: some View {
        _AttributedStringView(
            content: content,
            tappedURL: tappedURL,
            height: $height
        )
        .frame(height: height)
    }
}

private struct _AttributedStringView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding
    private var height: CGFloat
    private let content: NSAttributedString
    private let tappedURL: Binding<URL?>

    init(
        content: NSAttributedString,
        tappedURL: Binding<URL?>,
        height: Binding<CGFloat>
    ) {
        self.content = content
        self.tappedURL = tappedURL
        self._height = height
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.delegate = context.coordinator
        view.linkTextAttributes = [:]

        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        view.attributedText = content

        let newHeight = view.sizeThatFits(CGSize(
            width: view.frame.width,
            height: .infinity
        )).height

        DispatchQueue.main.async {
            height = newHeight
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tappedURL: tappedURL)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding
        var tappedURL: URL?

        init(tappedURL: Binding<URL?>) {
            self._tappedURL = tappedURL
        }

        func textView(
            _ textView: UITextView,
            shouldInteractWith url: URL,
            in characterRange: NSRange,
            interaction: UITextItemInteraction
        ) -> Bool {
            tappedURL = url
            return false
        }
    }
}
