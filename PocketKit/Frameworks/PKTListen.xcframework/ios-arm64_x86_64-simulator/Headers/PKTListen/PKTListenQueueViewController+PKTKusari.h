//
//  PKTListenQueueViewController+PKTKusari.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/13/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenQueueViewController.h"
#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenQueueViewController (PKTKusari)

- (NSIndexPath *_Nullable)indexPathForKusari:(PKTKusari<id<PKTListenItem>> *)kusari;


- (PKTKusari<id<PKTListenItem>> *_Nullable)kusariAtIndexPath:(NSIndexPath *)indexPath;


- (void)scrollToKusari:(PKTKusari<id<PKTListenItem>>*_Nullable)kusari animated:(BOOL)animated;


- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)selectKusari:(PKTKusari<id<PKTListenItem>> *)kusari animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)position;

@end

NS_ASSUME_NONNULL_END
