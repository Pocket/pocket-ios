//
//  PKTFeedItemPost.h
//  RIL
//
//  Created by Larry Tran on 10/16/15.
//
//

#import "PKTModelCodable.h"

@import Foundation;

@class PKTUserProfile, PKTFeedItemPostCount;

NS_ASSUME_NONNULL_BEGIN

@interface PKTFeedItemPost : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (copy, nonatomic, readonly) NSString *comment;
@property (copy, nonatomic, readonly) NSString *postId;
@property (copy, nonatomic, readonly) NSString *quote;
@property (assign, nonatomic, readonly) BOOL isLiked;
@property (assign, nonatomic, readonly) BOOL isReposted;
@property (assign, nonatomic, readonly) NSTimeInterval timeShared;
@property (strong, nonatomic, readonly, nullable) PKTUserProfile *user;
@property (strong, nonatomic, readonly) PKTFeedItemPost *originalPost;
@property (strong, nonatomic, readonly) PKTFeedItemPostCount *likeCount;
@property (strong, nonatomic, readonly) PKTFeedItemPostCount *repostCount;
@property (strong, nonatomic, readonly) NSDictionary *format;

/// Shareable URL for feed item post
@property (strong, nonatomic, readonly) NSURL *shareableURL;

@end

NS_ASSUME_NONNULL_END
