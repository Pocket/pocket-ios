//
//  PKTFormattedText.h
//  RIL
//
//  Created by Michael Schneider on 1/24/16.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTFeedItemPostCount, PKTFeedItemFormatUrl, PKTTweet;

@interface PKTFormattedText : NSObject <PKTModelCodable>

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithFeedItemPostCounts:(PKTFeedItemPostCount *)likeCount feedItemPostRepostCount:(PKTFeedItemPostCount *)repostCount;

@property (strong, nonatomic, readonly) NSDictionary *icon;
@property (copy, nonatomic, readonly) NSString *text;
@property (copy, nonatomic, readonly) NSArray<PKTFeedItemFormatUrl *> *urls;

@end

NS_ASSUME_NONNULL_END
