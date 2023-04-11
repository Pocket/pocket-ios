//
//  PKTPocketNotification.h
//  RIL
//
//  Created by Larry Tran on 11/4/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"
#import "PKTUserProfileProtocol.h"

@class PKTPocketNotificationItem, PKTPocketNotificationTextUrl, PKTPocketNotificationActions, PKTFeedItemPost;

NS_ASSUME_NONNULL_BEGIN

@interface PKTPocketNotification : NSObject <PKTModelCodable, NSCopying>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (nonatomic, strong, readonly, nullable) id<PKTUserProfileProtocol> user;
@property (nonatomic, copy, readonly) NSString *userNotificationId;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *timeAdded;
@property (nonatomic, copy, readonly) NSString *destinationUrl;
@property (nonatomic, copy, readonly) NSString *notificationQuote;
@property (nonatomic, copy, readonly) NSArray <PKTPocketNotificationTextUrl *> *textUrls;
@property (nonatomic, copy, readonly) NSArray <PKTPocketNotificationActions *> *actions;
@property (nonatomic, strong, readonly) PKTPocketNotificationItem *item;
@property (nonatomic, strong, readonly, nullable) PKTFeedItemPost *post;

@end

NS_ASSUME_NONNULL_END

