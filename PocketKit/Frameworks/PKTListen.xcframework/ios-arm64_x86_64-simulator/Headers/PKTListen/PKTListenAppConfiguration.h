//
//  PKTListenAppConfiguration.h
//  PKTListen
//
//  Created by Daniel Brooks on 3/26/23.
//  Copyright © 2023 PKT. All rights reserved.
//
#import "PKTListen.h"

NS_ASSUME_NONNULL_BEGIN


#pragma - PKTListenAppKusariConfiguration

@interface PKTListenAppKusariConfiguration : NSObject <PKTListenKusariConfiguration>

@end

#pragma - PKTListenAppConfiguration

// If enabled, you can fake offline/online connectivity by tapping on a button during runtime
#define PKTListenAppConfigurationEnableManualConnectionType 1

@interface PKTListenAppConfiguration : NSObject <PKTListenConfiguration>

- (instancetype)initWithSource:(id)source NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (void)setConnection:(PKTNetworkConnectionType)type;

@end

NS_ASSUME_NONNULL_END
