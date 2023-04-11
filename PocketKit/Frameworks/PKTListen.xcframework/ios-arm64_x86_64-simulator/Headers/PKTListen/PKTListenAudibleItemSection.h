//
//  PKTListenAudibleItemSection.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/9/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "IGListKit/IGListKit.h"

#import "PKTListenItem.h"
#import "PKTKusariSectionController.h"

@protocol PKTAudibleQueue;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemSection : PKTKusariSectionController <id<PKTListenItem>>

@property (atomic, readonly, strong, nullable) PKTKusariContainer<PKTKusari<id<PKTListenItem>>*> *kusari;
@property (nonatomic, readonly, strong, nullable) id<PKTListenFeedSource> source;
@property (nonatomic, readonly, copy, nonnull) NSOrderedSet<PKTKusari<id<PKTListenItem>> *> *list;

@end

NS_ASSUME_NONNULL_END
