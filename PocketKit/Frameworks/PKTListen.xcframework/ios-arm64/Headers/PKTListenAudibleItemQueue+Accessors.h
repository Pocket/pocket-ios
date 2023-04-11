//
//  PKTListenAudibleItemQueue+Accessors.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenAudibleItemQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemQueue (Accessors)

@property (atomic, readonly, strong, nonnull) id<PKTListenFeedSource> source;

@property (nonatomic, readwrite, assign) NSInteger speedFactor;

- (void)stageBegin;

- (void)stageEnd;

@end

NS_ASSUME_NONNULL_END
