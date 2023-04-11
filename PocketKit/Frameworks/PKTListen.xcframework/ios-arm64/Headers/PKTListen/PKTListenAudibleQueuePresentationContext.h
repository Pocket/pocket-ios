//
//  PKTListenAudibleQueuePresentationContext.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/20/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

#import "PKTAudibleQueue.h"

/**
 <PKTListenAudibleQueuePresentationContext> describes any object that manages the presentation of an audible queue.
 It's responsibilities include the presentation of ephemeral messages, warnings, and errors, and the ability to describe
 which items are currently visible. There can be multiple instances of this protocol initialized at any given moment,
 but it is intended that only one should be used for the purposes of messaging at any given time.
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTListenPresentationType) {
    PKTListenPresentationTypeList,
    PKTListenPresentationTypeItem,
};

@protocol PKTListenAudibleQueuePresentationContext <NSObject>

@property (nullable, nonatomic, readonly) id<PKTAudibleQueue> audibleQueue;
@property (nullable, nonatomic, readonly) UIView *view;

@optional

@property (nonnull, nonatomic, readonly) NSArray<PKTKusari<id<PKTListenItem>>*> *visibleKusari;
@property (nullable, nonatomic, readonly) NSDictionary <NSString*, id> *context;

- (void)pushMessage:(NSString *_Nonnull)messageText;

- (void)pushWarning:(NSString *_Nonnull)warning;

- (void)pushAnnouncement:(NSString *_Nonnull)announcement;

- (void)pushError:(NSError *_Nonnull)error;

@end

NS_ASSUME_NONNULL_END
