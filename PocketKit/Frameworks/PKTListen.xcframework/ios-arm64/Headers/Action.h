//
//  Action.h
//  RIL
//
//  Created by Nate Weiner on 10/18/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

@import Foundation;

#import "PKTSharedEnums.h"

@class PKTItem;

NS_ASSUME_NONNULL_BEGIN

@interface Action : NSObject

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, assign, getter = actionId) ActionId actionId;

+ (instancetype)fromDictionary:(NSDictionary *)dictionary;
+ (instancetype)action:(NSString *)action;
+ (instancetype)action:(NSString *)action data:(NSDictionary * _Nullable)data;
+ (instancetype)action:(NSString *)action data:(NSDictionary * _Nullable)data context:(NSDictionary * _Nullable)context;
+ (instancetype)action:(NSString *)action uniqueId:(NSNumber *)uniqueId
                itemId:(NSNumber * _Nullable)itemId;

+ (instancetype)action:(NSString *)action
              uniqueId:(NSNumber *)uniqueId
                itemId:(NSNumber * _Nullable)itemId
                  data:(NSDictionary * _Nullable)data
               context:(NSDictionary * _Nullable)context;

- (instancetype)initWithAction:(NSString *)action
                      uniqueId:(NSNumber *)uniqueId
                        itemId:(NSNumber *_Nullable)itemId
                          data:(NSDictionary * _Nullable)data
                       context:(NSDictionary * _Nullable)context;

- (id)attr:(NSString *)key;
- (void)setObject:(id)object forKey:(id)aKey;

- (NSDictionary *)JSONString;

- (void)commitAction;
- (void)commitDelayedAction;

@end

NS_ASSUME_NONNULL_END

