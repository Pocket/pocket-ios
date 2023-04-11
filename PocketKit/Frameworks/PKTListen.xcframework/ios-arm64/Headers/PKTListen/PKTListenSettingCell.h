//
//  PKTListenSettingCell.h
//  Listen
//
//  Created by David Skuza on 2/7/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PKTListenSettingCell;
@class PKTListenSettingViewModel;

/**
 Describes an interface for an object that responds to cell actions.
 */
@protocol PKTListenSettingCellDelegate
/**
 Called when a cell contains a switch as an accessory item, and the switch has been toggled.

 @param cell The cell whose switch was toggled.
 @param on The value of the switch after being toggled.
 */
- (void)listenSettingCell:(PKTListenSettingCell *)cell toggledSwitch:(BOOL)on;
@end

/**
 A UICollectionViewCell that is used to present various settings and settings options.
 These cells are bound to view models of type PKTListenSettingViewModel.
 */
@interface PKTListenSettingCell : UICollectionViewCell

/**
 Returns the suggested size for a view model that wants to be bound to the cell.

 @param viewModel The view model that wants to be bound to the cell.
 @param containerSize The size in which the cell will be presented.
 @return A CGSize value representing the size the cell should be, after binding the view model.
 */
+ (CGSize)sizeForViewModel:(PKTListenSettingViewModel *)viewModel containerSize:(CGSize)containerSize;

/**
 The delegate to call when certain cell actions take place.
 */
@property (nonatomic, weak) id<PKTListenSettingCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
