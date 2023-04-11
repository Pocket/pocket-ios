//
//  PKTFeedItemPostCount.h
//  RIL
//
//  Created by Larry Tran on 3/9/16.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTFeedItemPostCount : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (nonatomic, assign, readonly) NSInteger count;
@property (nonatomic, copy, readonly) NSString *url;

@end

NS_ASSUME_NONNULL_END
