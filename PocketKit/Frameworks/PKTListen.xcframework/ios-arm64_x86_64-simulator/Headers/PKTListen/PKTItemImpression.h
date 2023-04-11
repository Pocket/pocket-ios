//
//  PKTItemImpression.h
//  Pocket
//
//  Created by Larry Tran on 6/1/18.
//

#import <Foundation/Foundation.h>
#import "PKTImpressionTrackingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTItemImpression : NSObject <PKTImpressionTrackingProtocol>

- (instancetype)initWithItemId:(NSNumber *)itemId indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
