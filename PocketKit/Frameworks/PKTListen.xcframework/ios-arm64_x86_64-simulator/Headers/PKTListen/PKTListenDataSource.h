//
//  PKTListenDataSource.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 10/30/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

#import "PKTFeedSource.h"
#import "PKTKusari.h"
#import "PKTKusari+PKTListen.h"

#import "IGListKit/IGListKit.h"

NS_ASSUME_NONNULL_BEGIN


#pragma mark - PKTListenDataSource

@interface PKTListenDataSource <__covariant T:id<PKTListDiffable>> : NSObject <NSObject>

typedef void (^PKTListenDataSourceComplete)(NSError *_Nullable error,
                                            NSDictionary *_Nullable context,
                                            NSArray<T> *_Nullable list);

typedef void (^PKTListenDataSourceLoad)(id<PKTMutableListenDataSource> _Nonnull source,
                                        NSDictionary *_Nullable context,
                                        PKTListenDataSourceComplete complete);

//PKTListenDataSource<PKTMutableListenDataSource> * _Nonnull source,
//         NSDictionary * _Nullable context,
//         PKTListenDataSourceComplete  _Nonnull complete

@property (atomic, readonly, copy, nullable) NSDictionary *context;
@property (atomic, readonly, assign, getter=hasMore) BOOL more;
@property (atomic, readonly, assign, getter=isLoading) BOOL loading;
@property (atomic, readonly, strong, nullable) PKTKusariContainer<PKTKusari<T>*> *kusari;
@property (atomic, readonly, strong, nonnull) PKTKusari<id<PKTListDiffable>> *state; // KVO Observable
@property (nonatomic, readonly, copy, nonnull) void (^mutate)(void(^mutator)(id<PKTMutableListenDataSource> source, dispatch_block_t finished));

- (void)reload;

- (void)deleteObject:(PKTKusari<T>*)object;

- (void)replaceObject:(PKTKusari<T>*)object replacement:(PKTKusari<T>*)replacement;

@end

#pragma mark - PKTListenDataSource+IGListAdapterDataSource

@interface PKTListenDataSource <__covariant T:id<PKTListDiffable>> (IGListAdapterDataSource) <IGListAdapterDataSource>

typedef IGListSectionController *_Nonnull (^PKTListenDataSourceSectionProvider)(T);

typedef NSArray<id<PKTListDiffable>> *_Nonnull (^PKTListenDataSourceObjectsProvider)(PKTKusariContainer<PKTKusari<T>*> *kusari);


- (void)setSectionProvider:(PKTListenDataSourceSectionProvider)sectionProvider forAdapter:(IGListAdapter *)adapter;

- (void)setObjectsProvider:(PKTListenDataSourceObjectsProvider)sectionProvider forAdapter:(IGListAdapter *)adapter;

@end

#pragma mark - PKTListenDataSource+PKTFeedSource

@interface PKTListenDataSource <__covariant T:id<PKTListDiffable>> (PKTFeedSource) <PKTListenFeedSource>

@property (atomic, readonly, assign, getter=hasMore) BOOL more;
@property (atomic, readonly, assign, getter=isLoading) BOOL loading;
@property (atomic, readonly, strong, nonnull) NSArray<PKTKusari<T>*> *list;

@end

#pragma mark - PKTListenDataSource+PKTInteractiveFeedSource

@interface PKTListenDataSource (PKTInteractiveFeedSource) <PKTInteractiveFeedSource>

- (instancetype)initWithContext:(NSDictionary *_Nullable)context loader:(nonnull PKTListenDataSourceLoad)block;

- (void)loadMore;

@end

NS_ASSUME_NONNULL_END
