//
//  PKTListenItemCollectionViewCell.h
//  Listen
//
//  Created by Nicholas Zeltzer on 8/4/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListenItem.h"

#define PKTLayoutWithCorrectPadding 0

@class PKTKusari;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenItemCollectionViewCell : UICollectionViewCell

@property (atomic, readwrite, strong, nullable) PKTKusari<id<PKTListenItem>> *kusari;
@property (nonatomic, readonly, strong, nonnull) NSLayoutConstraint *width;
@property (nonatomic, readwrite, strong, nonnull) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, readwrite, strong, nonnull) UIColor *titleSelectedStateColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, readwrite, strong, nonnull) UIColor *detailColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, readwrite, strong, nonnull) UIColor *dividerColor UI_APPEARANCE_SELECTOR;

- (void)setKusari:(PKTKusari<id<PKTListenItem>> *_Nullable)kusari force:(BOOL)forceUpdate;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
