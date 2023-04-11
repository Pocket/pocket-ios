//
//  PKTListenItemCollectionViewCell+PKTSizing.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/13/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenItemCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenItemCollectionViewCell (PKTSizing)

+ (instancetype)sizing;
+ (CGSize)sizeForKusari:(PKTKusari<id<PKTListenItem>> *_Nullable)kusari
    inContainerWithSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
