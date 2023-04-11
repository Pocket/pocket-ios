//
//  PKTListenCacheManager+Settings.h
//  PKTListen
//
//  Created by David Skuza on 2/21/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import "PKTListenCacheManagerPrivate.h"
#import "PKTListenSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Describes the interface of an object that can retrieve and update user settings via any mean of persistence.
 Some possibilities are in-memory, NSUserDefaults, on-disk, or database.
 */
@protocol PKTListenStore <NSObject>

/**
 A copy of user-configurable Listen settings.
 */
@property (nonatomic, copy) PKTListenSettings *userSettings;

@end

@interface PKTListenCacheManager (Settings) <PKTListenStore>

@end

NS_ASSUME_NONNULL_END
