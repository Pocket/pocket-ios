//
//  PKTFeedItemFormatUrl.h
//  RIL
//
//  Created by Larry Tran on 3/31/16.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTFeedItemFormatUrl : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (strong, nonatomic, readonly, nullable) NSURL *url;
@property (assign, nonatomic, readonly) NSRange range;

@end

NS_ASSUME_NONNULL_END
