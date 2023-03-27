//
//  PKTListenAppItemSource.h
//  Listen
//
//  Created by Nicholas Zeltzer on 8/6/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;

#import "PKTFeedSource.h"
#import "PKTListenItem.h"
#import "PKTListenDataSource.h"

@protocol PKTListenKusariConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAppLocalItemSource : PKTListenDataSource <PKTListenFeedSource>

+ (instancetype)source:(id<PKTListenKusariConfiguration>)configuration;

@end

@interface PKTListenAppSingleItemSource : PKTListenAppLocalItemSource

+ (instancetype)source:(id<PKTListenKusariConfiguration>)configuration;

@end

NS_ASSUME_NONNULL_END
