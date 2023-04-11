//
//  PKTFeedItemImpressionInfo.h
//  RIL
//
//  Created by Larry Tran on 5/9/16.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTFeedItemDisplay, PKTDisplay, PKTFeedItemImpressionTimer;

@interface PKTFeedItemImpressionInfo : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (strong, nonatomic, readonly) NSArray <NSString *>*im;
@property (copy, nonatomic, readonly) NSString *impressionId;
@property (copy, nonatomic, readonly) NSString *type; // Should be transformed into a enum
@property (strong, nonatomic, readonly) PKTFeedItemDisplay *display;
@property (strong, nonatomic) PKTFeedItemImpressionTimer *impressionTimer;

@end

NS_ASSUME_NONNULL_END
