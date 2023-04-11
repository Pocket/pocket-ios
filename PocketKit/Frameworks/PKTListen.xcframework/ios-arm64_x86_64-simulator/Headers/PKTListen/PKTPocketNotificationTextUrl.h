//
//  PKTPocketNotificationTextUrl.h
//  RIL
//
//  Created by Larry Tran on 11/20/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTPocketNotificationTextUrl : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (nonatomic, assign, readonly) NSRange range;
@property (nonatomic, copy, readonly) NSString *url;

@end

NS_ASSUME_NONNULL_END
