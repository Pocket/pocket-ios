//
//  PKTPocketNotificationActions.h
//  RIL
//
//  Created by Larry Tran on 11/4/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTPocketNotificationActions : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

- (NSString *)preferredDisplayText;

@property (nonatomic, copy, readonly) NSString *actionName;
@property (nonatomic, copy, readonly) NSDictionary *data;
@property (nonatomic, assign) BOOL actionTaken;

@end

NS_ASSUME_NONNULL_END
