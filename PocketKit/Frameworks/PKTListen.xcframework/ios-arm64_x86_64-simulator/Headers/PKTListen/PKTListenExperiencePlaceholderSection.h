//
//  PKTQueueCoverFlowSection.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "IGListKit/IGListKit.h"

@protocol PKTAudibleQueue;

@interface PKTListenExperiencePlaceholderSection : IGListSectionController

@property (nullable, nonatomic, readwrite, strong) id<PKTAudibleQueue> audibleQueue;

@end
