//
//  PKTListenCoverFlowCollectionViewLayout.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/12/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTListenCoverFlowLayoutType) {
    PKTListenCoverFlowLayoutTypeRows,
    PKTListenCoverFlowLayoutTypeSections,
};

@interface PKTListenCoverFlowCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, readwrite, assign) CGFloat horizontalCompression;
@property (nonatomic, readwrite, assign) CGFloat verticalCompression;

@property (nonatomic, readonly, assign) PKTListenCoverFlowLayoutType type;

- (instancetype)initWithLayoutType:(PKTListenCoverFlowLayoutType)type NS_DESIGNATED_INITIALIZER;

- (NSInteger)indexForContentOffset:(CGPoint)offset;

- (CGPoint)contentOffsetForIndex:(NSInteger)idx;

- (void)scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated;

- (CGPoint)proposedContentOffset:(CGPoint)velocity;

- (NSIndexPath *)indexPathForIndex:(NSUInteger)idx;

- (NSUInteger)indexForIndexPath:(NSIndexPath *)path;

@end

NS_ASSUME_NONNULL_END
