//
//  PKTKusariSectionController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/22/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;
#import "IGListKit/IGListKit.h"

#import "PKTListenDataSource.h"
#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTKusari;
@protocol PKTListDiffable;

@protocol PKTKusariSectionController <NSObject>

@property (atomic, readonly, strong, nullable) PKTKusariContainer<PKTKusari<id<PKTListDiffable>>*> *kusari;
@property (nonatomic, readonly, strong, nullable) id<PKTInteractiveFeedSource> source;
@property (nonatomic, readonly, copy, nonnull) NSOrderedSet<PKTKusari<id<PKTListDiffable>> *> *list;


+ (CGSize)sectionController:(IGListSectionController<PKTKusariSectionController> *)section
         sizeForItemAtIndex:(NSInteger)index;

+ (__kindof UICollectionViewCell *_Nullable)sectionController:(IGListSectionController<PKTKusariSectionController> *)section
                                  cellForItemAtIndex:(NSInteger)index;

@end

@interface PKTKusariSectionController <__covariant T:id<PKTListDiffable>> : IGListBindingSectionController <PKTKusariSectionController, IGListBindingSectionControllerSelectionDelegate> {
@protected id<PKTInteractiveFeedSource> _source;
@protected PKTKusariContainer<PKTKusari<id<PKTListDiffable>>*> *_kusari;
}

@property (nullable, nonatomic, readonly, weak) UICollectionView *collectionView;

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath
                      ofObject:(id _Nullable)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change
                       context:(void *_Nullable)context NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
