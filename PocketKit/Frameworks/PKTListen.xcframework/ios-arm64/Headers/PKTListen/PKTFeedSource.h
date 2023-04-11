//
//  PKTFeedSource.h
//  Listen
//
//  Created by Nicholas Zeltzer on 8/4/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTKusari;
@protocol PKTListenItem;

#pragma mark - PKTFeedSource

@protocol PKTFeedSource <NSObject>

@property (atomic, readonly, assign, getter=hasMore) BOOL more;
@property (atomic, readonly, assign, getter=isLoading) BOOL loading;
/// KVO Observable. Signalled when loading completes.
@property (atomic, readonly, strong, nonnull) PKTKusari<id<PKTListDiffable>> *state; // KVO Observable
@property (atomic, readonly, strong, nonnull) PKTKusariContainer<PKTKusari<id<PKTListDiffable>>*> *kusari;
@property (atomic, readonly, strong, nonnull) NSArray<id> *list;

@end

#pragma mark - PKTInteractiveFeedSource

@protocol PKTInteractiveFeedSource <PKTFeedSource>

- (void)loadMore;

- (void)reload;

@end

#pragma mark - PKTMutableFeedSource

@protocol PKTMutableFeedSource <PKTFeedSource>

@property (atomic, readwrite, assign, getter=hasMore) BOOL more;
@property (atomic, readwrite, assign, getter=isLoading) BOOL loading;
@property (atomic, readwrite, strong, nonnull) PKTKusariContainer<PKTKusari<id<PKTListDiffable>>*> *kusari;

@end

#pragma mark - PKTMutableListenDataSource

@protocol PKTMutableListenDataSource <PKTMutableFeedSource>

@property (atomic, readwrite, assign, getter=hasMore) BOOL more;
@property (atomic, readwrite, assign, getter=isLoading) BOOL loading;
@property (atomic, readwrite, strong, nullable) PKTKusariContainer<PKTKusari<id<PKTListDiffable>>*> *kusari;

@end

@protocol PKTListenFeedSource <PKTInteractiveFeedSource>

@property (atomic, readonly, strong, nonnull) NSArray<PKTKusari<id<PKTListDiffable>>*> *list;
@property (atomic, readonly, strong, nonnull) PKTKusari<id<PKTListDiffable>> *state; // KVO Observable
@property (nonatomic, readonly, copy, nonnull) void (^mutate)(void(^mutator)(id<PKTMutableListenDataSource> source, dispatch_block_t finished));

@end

NS_ASSUME_NONNULL_END
