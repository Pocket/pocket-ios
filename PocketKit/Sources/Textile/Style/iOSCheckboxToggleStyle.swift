// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/**
 Inspiration taken from  https://sarunw.com/posts/swiftui-checkbox/
 */

import SwiftUI

public struct iOSCheckboxToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                if configuration.isOn {
                    SFIcon(SFIconModel("checkmark.square.fill", color: Color(.ui.white1), secondaryColor: Color(.ui.teal2)))
                } else {
                    SFIcon(SFIconModel("square", color: Color(.ui.grey3)))
                }
                configuration.label
            }
            .foregroundColor(Color(.ui.black1))

        })
    }
}

struct iOSCheckboxToggleStyle_PreviewProvider: PreviewProvider {
    static var previews: some View {
        VStack {
            Toggle(isOn: .constant(true), label: {
                Text("Toggle On")
            })
            .padding()
            .toggleStyle(iOSCheckboxToggleStyle())

            Toggle(isOn: .constant(false), label: {
                Text("Toggle Off")
            })
            .toggleStyle(iOSCheckboxToggleStyle())
        }
        .previewDisplayName("Light")
        .preferredColorScheme(.light)
        
        VStack {
            Toggle(isOn: .constant(true), label: {
                Text("Toggle On")
            })
            .padding()
            .toggleStyle(iOSCheckboxToggleStyle())

            Toggle(isOn: .constant(false), label: {
                Text("Toggle Off")
            })
            .toggleStyle(iOSCheckboxToggleStyle())
        }
        .previewDisplayName("Dark")
        .preferredColorScheme(.dark)
    }
}
