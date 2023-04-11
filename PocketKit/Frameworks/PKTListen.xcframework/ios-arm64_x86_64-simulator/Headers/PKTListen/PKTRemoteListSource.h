//
//  PKTRemoteListSource.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "PKTFeedSource.h"
#import "PKTListenItem.h"
#import "PKTListenDataSource.h"

@protocol PKTListenItem;
@protocol PKTListenKusariConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PKTRemoteListSource : PKTListenDataSource <PKTListenFeedSource>

+ (instancetype)source:(NSDictionary<NSString*, id> *)context
         configuration:(id<PKTListenKusariConfiguration>)configuration;

@end

NS_ASSUME_NONNULL_END
