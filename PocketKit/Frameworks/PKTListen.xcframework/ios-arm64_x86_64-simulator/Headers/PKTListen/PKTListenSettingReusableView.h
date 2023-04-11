//
//  PKTListenSettingReusableView.h
//  PKTListen
//
//  Created by David Skuza on 2/11/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A UICollectionReusableView that is used to display headers related to Listen settings.
 */
@interface PKTListenSettingReusableView : UICollectionReusableView

/**
 A label that can be used to present text for the header.
 */
@property (nonatomic, readonly) UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
