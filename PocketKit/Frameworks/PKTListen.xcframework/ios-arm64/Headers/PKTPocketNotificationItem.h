//
//  PKTPocketNotificationItem.h
//  RIL
//
//  Created by Larry Tran on 11/19/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTPocketNotificationItem : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *domain;

@end

NS_ASSUME_NONNULL_END
