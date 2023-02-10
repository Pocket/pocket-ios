//
//  Home.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation

struct HomeArticleContentOpen: AppEvent {
    
    init(slateTitle: String, positionInSlate: Int) {
        
    }
    var event: Event = ContentOpenEvent(destination: .internal, trigger: .click)
    var entities: [Entity] = [
        UIEntity(type: .card, identifier: .home)//"home.article.open")
    ]
}
