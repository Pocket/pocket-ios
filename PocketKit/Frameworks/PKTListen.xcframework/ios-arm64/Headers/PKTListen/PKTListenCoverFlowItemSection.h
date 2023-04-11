//
//  PKTListenCoverFlowItemSection.h
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

UIKIT_EXTERN NSString * const PKTListenCoverFlowItemSectionDummyIdentifier;

@interface PKTListenCoverFlowItemSection : PKTKusariSectionController

@property (atomic, readonly, strong, nullable) id<PKTListenFeedSource> source;
@property (atomic, readonly, strong, nullable) PKTKusariContainer<PKTKusari<id<PKTListenItem>>*> *kusari;
@property (atomic, readonly, copy, nonnull) NSOrderedSet<PKTKusari<id<PKTListenItem>> *> *list;

@end

NS_ASSUME_NONNULL_END
