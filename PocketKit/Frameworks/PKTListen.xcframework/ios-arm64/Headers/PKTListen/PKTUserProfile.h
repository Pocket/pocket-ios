//
//  PKTUserProfile.h
//  PKTTopTabBarViewController
//
//  Created by Michael Schneider on 10/1/15.
//  Copyright © 2015 Read It Later Inc. All rights reserved.
//

#import "PKTUserProfileProtocol.h"
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTUserProfile : NSObject <PKTUserProfileProtocol, PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
