//
//  PKTListenAudibleItemQueue.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "PKTAudioStream.h"
#import "PKTFeedSource.h"
#import "PKTAudibleQueue.h"

@protocol PKTListenConfiguration;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTAudibleQueueErrorCode) {
    PKTAudibleQueueErrorCodeUndefined,
    PKTAudibleQueueUnderlyingNetworkErrorCode,
    PKTAudibleQueueErrorCodeInvalidStream,
};

typedef NS_ENUM(NSInteger, PKTAudibleQueueInitialPlayType) {
    PKTAudibleQueueInitialPlayTypeFirst,
    PKTAudibleQueueInitialPlayTypeFirstUnlistened
};

@interface PKTListenAudibleItemQueue : NSObject

@property (atomic, readonly, strong, nullable) PKTKusari<id<PKTListenItem>> *staged;
@property (nonatomic, readonly, strong, nonnull) id<PKTListenConfiguration> configuration;

- (instancetype)initWithConfiguration:(id<PKTListenConfiguration>)configuration;

@end

@interface PKTListenAudibleItemQueue (Conformance) <PKTAudibleQueue, PKTListDiffable>

- (instancetype)initWithConfiguration:(id<PKTListenConfiguration>)configuration;

@end

NS_ASSUME_NONNULL_END
