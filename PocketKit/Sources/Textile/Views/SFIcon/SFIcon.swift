//
//  SFIcon.swift
//  
//
//  Created by Ky B Hamilton on 8/29/22.
//

import SwiftUI

public struct SFIcon: View {
    
    var model: SFIconModel
    
    public init(_ model: SFIconModel) {
        self.model = model
    }
    
    public var body: some View {
        Image(systemName: model.systemImage)
            .resizable()
            .scaledToFit()
            .font(.system(size: model.size, weight: model.weight, design: .monospaced))
            .rotationEffect(.degrees(model.rotation))
            .frame(width: model.size, height: model.size)
            .imageScale(.small)
            .symbolRenderingMode(.palette)
            .foregroundStyle(model.color)
    }
}
