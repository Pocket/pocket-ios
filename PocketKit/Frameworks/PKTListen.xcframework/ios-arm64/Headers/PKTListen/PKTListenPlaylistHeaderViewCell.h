//
//  PKTListenPlaylistHeaderViewCell.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/16/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenPlaylistHeaderViewCell : UICollectionViewCell

@property (nonnull, nonatomic, readonly, strong) NSLayoutConstraint *width;
@property (nonnull, nonatomic, readonly, strong) UIView *divider;
@property (nullable, nonatomic, readwrite, strong) UIColor *dividerColor UI_APPEARANCE_SELECTOR;
@property (nullable, nonatomic, readwrite, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nullable, nonatomic, readwrite, strong) PKTKusari<NSString<PKTListDiffable>*> *kusari;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
