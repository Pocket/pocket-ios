//
//  PKTActivityShareItem.h
//  Pocket
//
//  Created by Larry Tran on 8/20/19.
//

NS_ASSUME_NONNULL_BEGIN

@protocol PKTActivityShareItem <NSObject>

- (NSURL *)activityShareUrl;
- (NSData * _Nullable)activityShareData;
- (NSURL * _Nullable)activityShareImageUrl;
- (NSString *)activityShareTitle;
- (NSInteger)activityShareWordCount;

@end

NS_ASSUME_NONNULL_END
