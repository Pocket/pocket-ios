//
//  PKTNotification.h
//  RIL
//
//  Created by Nate Weiner on 10/9/12.
//
//

@import Foundation;

#import "PKTSharedEnums.h"
#import "PKTModelCodable.h"

@class PKTItem;
@class PKTFriend;
@class PKTShare;

NS_ASSUME_NONNULL_BEGIN

@interface PKTNotification : NSObject <PKTModelCodable>

+ (instancetype)pendingItemNotificationWithItem:(PKTItem *)item share:(PKTShare *)share;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (nonatomic, assign) PKTNotificationType notificationType;
@property (nonatomic, retain) PKTItem *item;
@property (nonatomic, retain) PKTShare *share;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, retain) NSMutableDictionary *data;

- (PKTFriend *)friend;

@end

NS_ASSUME_NONNULL_END
