//
//  PKTListenAudibleItemThumbnailView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/20/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, PKTListenItemCollectionViewCellAspectRatio) {
    PKTListenItemCollectionViewCellAspectRatioUndefined  = 0 << 0,
    PKTListenItemCollectionViewCellAspectRatioNone       = 1 << 0,
    PKTListenItemCollectionViewCellAspectRatioSquare     = 1 << 1,
    PKTListenItemCollectionViewCellAspectRatioLandscape  = 1 << 2,
    PKTListenItemCollectionViewCellAspectRatioPortrait   = 1 << 3,
};

@interface PKTListenAudibleItemThumbnailView : UIView

@property (nullable, nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, assign) CGSize maxSize;
@property (nonatomic, readwrite, assign) CGSize minSize;
@property (nonatomic, readwrite, assign) CGSize squareSize;
@property (nonatomic, readwrite, assign) PKTListenItemCollectionViewCellAspectRatio supportedRatios;

@end

NS_ASSUME_NONNULL_END
