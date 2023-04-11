//
//  PKTActionTrace.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 12/14/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;

@class Action;

NS_ASSUME_NONNULL_BEGIN

@interface PKTActionTrace : NSObject

@property (nonatomic, readonly, strong, nonnull) NSString *name;
@property (nonatomic, readonly, assign, getter=isActive) BOOL active;

- (instancetype)initWithName:(NSString *_Nonnull)name filter:(BOOL(^)(Action *_Nonnull action))filter;

- (void)setInfo:(NSDictionary *)userInfo forKey:(NSString *)key;

- (void)open;

- (void)close;

@end

@interface PKTActionTraceManager : NSObject

@property (atomic, readonly, strong, nonnull) NSArray<PKTActionTrace*> *traces; // KVO Observable

+ (instancetype)sharedInstance;

- (void)getTraceWithName:(NSString *_Nonnull)trace completion:(void(^)(PKTActionTrace *_Nullable trace))completion;

- (void)getTraces:(void(^)(NSArray<PKTActionTrace*> *_Nonnull traces))completion;

- (void)addTrace:(PKTActionTrace *_Nonnull)trace;

- (void)removeTraceWithName:(NSString *_Nonnull)name;

- (void)process:(Action *)action;

- (void)purge;

@end

NS_ASSUME_NONNULL_END
