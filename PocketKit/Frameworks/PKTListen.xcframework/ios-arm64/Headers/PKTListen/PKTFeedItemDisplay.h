//
//  PKTFeedItemDisplay.h
//  RIL
//
//  Created by Larry Tran on 5/9/16.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTFeedItemTrackFormat : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (copy, nonatomic, readonly) NSDictionary *header;

@end

@interface PKTFeedItemTrackImage : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (strong, nonatomic, readonly) NSURL *src;
@property (copy, nonatomic, readonly) NSString *imageId;

@end

@interface PKTFeedItemDisplay : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (assign, nonatomic, readonly) NSInteger position;
@property (copy, nonatomic, readonly) NSString *domain;
@property (strong, nonatomic, readonly, nullable) PKTFeedItemTrackImage *image;
@property (strong, nonatomic, readonly, nullable) PKTFeedItemTrackFormat *format;

@end

NS_ASSUME_NONNULL_END
