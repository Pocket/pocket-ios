//
//  PKTListenSettingsSection.h
//  Listen
//
//  Created by David Skuza on 2/8/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTListenSettingCell.h"

#import "IGListKit/IGListKit.h"

@protocol PKTListenStore;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines the "main" settings screen section, used to present high-level user options such as "selected voice" and "always use offline voices".
 */
@interface PKTListenSettingsSection : IGListBindingSectionController <IGListBindingSectionControllerDataSource, PKTListenSettingCellDelegate>

- (instancetype)init NS_UNAVAILABLE;
/**
 Initializes a new section with a store.

 @param store An object conforming to PKTListenStore that is used to return user settings.
 @return A new PKTListenSettingsSection used with PKTListenSettingsViewController.
 */
- (instancetype)initWithStore:(id<PKTListenStore>)store NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
