//
//  PKTListenItemSession.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/21/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

#import "PKTKusari+PKTListen.h"
#import "PKTListenItem.h"
#import "PKTAudibleQueue.h"
#import "PKTListenDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenItemSession : NSObject

+ (nullable instancetype)newSession:(PKTKusari<id<PKTListenItem>> *_Nullable)kusari
                             source:(id<PKTListenFeedSource>)source;

- (NSDictionary *_Nullable)willPlay:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willPause:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willArchive:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willSeek:(CMTime)time context:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willScrubFrom:(CGFloat)from to:(CGFloat)position context:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willSkipForwards:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willSkipBackwards:(NSDictionary *_Nullable)context;

- (NSDictionary *_Nonnull)willChangeRate:(float)rate view:(NSString *_Nullable)viewName;

- (NSDictionary *_Nonnull)willFinish:(NSDictionary *_Nullable)context;

/**
 Called when a Listen session wants to add (i.e "save") the current item, commonly from the Discover feed.
 
 @param context The context within which the current item was added.
 */
- (NSDictionary *_Nonnull)willAdd:(NSDictionary *_Nullable)context;

- (CGFloat)scrollAmount:(CMTime)time;

NSNumber * NSNumberTruncateCGFloat(CGFloat value, NSInteger significantDigits);

@end

UIKIT_EXTERN CGFloat const PKTListenItemSessionVisibilityHeightRequirement;

@interface PKTListenSession : NSObject

@property (nonnull, nonatomic, readonly, copy) NSString *sessionID;
@property (nonnull, nonatomic, readonly, strong) id<PKTAudibleQueue> audibleQueue;

+ (nullable instancetype)newSession:(id<PKTAudibleQueue>)audibleQueue;

- (void)willOpen:(NSDictionary<NSString*, id>*_Nullable)userInfo;

- (void)willClose:(NSDictionary<NSString*, id>*_Nullable)userInfo;

- (void)trackVisibleListKusari:(NSArray <PKTKusari<id<PKTListenItem>> *> *)visibleKusari;

- (void)madeImpression:(PKTKusari<id<PKTListenItem>> *)kusari context:(NSString *)contextUI;

@end

NS_ASSUME_NONNULL_END
