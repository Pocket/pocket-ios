//
//  PKTFeedItemImpression.h
//  RIL
//
//  Created by Larry Tran on 7/13/16.
//
//

#import <UIKit/UIKit.h>
#import "PKTImpressionTrackingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTFeedItemImpression : NSObject <PKTImpressionTrackingProtocol>

+ (instancetype)impressionForFeedItemWithId:(NSString *)feedItemId
                                     postId:(NSString *)postId
                                     itemId:(NSNumber *)itemId
                                  indexPath:(NSIndexPath *)indexPath
                               timeInterval:(NSTimeInterval)timeInterval;

@property (copy, nonatomic, readonly) NSString *feedItemId;
@property (copy, nonatomic, readonly) NSString *feedItemPostId;
@property (copy, nonatomic, readonly) NSNumber *itemId;
@property (copy, nonatomic, readonly) NSIndexPath *indexPath;
@property (copy, nonatomic) NSString *impressionId; // Optional impression ID for sponsored feed items
@property (nonatomic, strong) NSArray <NSString*> *imTags; // Optional im tags to be fired

@end

NS_ASSUME_NONNULL_END
