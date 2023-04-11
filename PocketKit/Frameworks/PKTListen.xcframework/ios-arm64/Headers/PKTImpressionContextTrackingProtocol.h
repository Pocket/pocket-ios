//
//  PKTFeedItemContextTrackingProtocol.h
//  RIL
//
//  Created by Larry Tran on 7/22/16.
//
//

@protocol PKTImpressionContextTrackingProtocol <NSObject>

- (void)trackAllVisibleImpressionsForRelativeView:(UIView *)view context:(NSDictionary *)context;

@end
