//
//  SwiftUIView.swift
//  
//
//  Created by Giorgio Ruscigno on 5/19/23.
//

import SwiftUI

struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        List(entry.content) { item in
            LabeledContent(item.title, value: item.url)
        }
    }
}

struct RecentSavesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSavesView(entry: RecentSavesEntry(date: Date(), content: [.placeHolder]))
    }
}
