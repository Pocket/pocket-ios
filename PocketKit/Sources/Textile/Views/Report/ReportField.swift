// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct ReportField: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 1
    }
    let userInput: Binding<String>
    let header: String
    let height: CGFloat

    var body: some View {
        Section(header: ReportHeader(title: header)) {
            TextField("", text: userInput)
                .style(.report.textStyle)
                .padding()
                .frame(height: height)
                .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius).strokeBorder(Color.black, style: StrokeStyle(lineWidth: Constants.lineWidth)))
        }.listRowInsets(EdgeInsets())
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ReportField(userInput: .constant("User Input"), header: "Header", height: 50)
        }
        .previewDisplayName("ReportField - Light")
        .preferredColorScheme(.light)

        Form {
            ReportField(userInput: .constant("User Input"), header: "Header", height: 50)
        }
        .previewDisplayName("ReportField - Dark")
        .preferredColorScheme(.dark)
    }
}
