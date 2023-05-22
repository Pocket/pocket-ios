//
//  SwiftUIView.swift
//  
//
//  Created by Giorgio Ruscigno on 5/19/23.
//

import SwiftUI

struct RecentSavesView: View {
    var body: some View {
        Text(Date(), style: .time)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSavesView()
    }
}
