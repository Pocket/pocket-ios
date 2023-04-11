//
//  PKTFeedItem.h
//  RIL
//
//  Created by Michael Schneider on 6/29/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"
#import "PKTSharedEnums.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTItemViewModel, PKTFriend, PKTFeedItemPost, PKTFormattedText, PKTFeedItemImpressionInfo;

@interface PKTFeedItem : NSObject <PKTModelCodable, NSCopying>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (strong, nonatomic, readonly) PKTItemViewModel *item;
@property (strong, nonatomic, readonly) PKTFeedItemPost *post;
@property (strong, nonatomic, readonly) PKTFeedItemImpressionInfo *impressionInfo;
@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (copy, nonatomic, readonly) NSString *feedItemId;
@property (copy, nonatomic, readonly) NSString *openAs;
@property (copy, nonatomic, readonly) NSNumber *sortId;
@property (copy, nonatomic, readonly) NSDictionary<NSString *, PKTFormattedText *> *format;
@property (copy, nonatomic, readonly) NSString *domain;
@property (copy, nonatomic, readonly) NSURL *shareableURL; /// Shareable URL for feed item

/// Returns the view type the item should be opened in
@property (assign, nonatomic, readonly) RILViewType viewTypeForToOpenAs;

/// @return YES if the item represents sponsored content; otherwise NO
/// @note This value will be true where the impressionInfo object contains a valid impression id, and its type is 'sp'.

@property (assign, nonatomic, readonly) BOOL isSponsoredContent;

@end

NS_ASSUME_NONNULL_END
