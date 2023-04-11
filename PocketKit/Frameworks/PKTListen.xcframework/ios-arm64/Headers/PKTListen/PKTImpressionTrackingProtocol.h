//
//  PKTImpressionTrackingProtocol.h
//  RIL
//
//  Created by Larry Tran on 3/21/17.
//
//

NS_ASSUME_NONNULL_BEGIN

@protocol PKTImpressionTrackingProtocol <NSObject>

- (NSDictionary *)contextDictionary;
- (NSString * _Nullable)impressionId;
- (NSTimeInterval)timeInterval;
- (NSString *)uuid;

@optional

- (NSArray *)imTags;

@end

NS_ASSUME_NONNULL_END
