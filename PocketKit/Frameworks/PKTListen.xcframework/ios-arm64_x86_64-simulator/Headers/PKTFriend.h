//
//  PKTFriend.h
//  RIL
//
//  Created by Nate Weiner on 8/16/12.
//  Copyright (c) 2012 Read It Later. All rights reserved.
//

@import Foundation;

#import "PKTPerson.h"
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTFriend : NSObject <PKTPerson, PKTModelCodable>

+ (PKTFriend *)friendWithShareDictionary:(NSDictionary *)dictionary;
+ (nullable PKTFriend *)friendWithDictionary:(NSDictionary *)dictionary;

@property (nullable, nonatomic, strong) NSNumber *localFriendId;
@property (nullable, nonatomic, strong) NSNumber *friendId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSString *avatarSrc;

@end

NS_ASSUME_NONNULL_END
