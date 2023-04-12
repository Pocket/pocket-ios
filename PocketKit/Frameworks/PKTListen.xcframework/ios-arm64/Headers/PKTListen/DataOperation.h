//
//  DataOperation.h
//  RIL
//
//  Created by Nate Weiner on 10/18/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataOperation;
typedef void (^DataOperationCallback)(DataOperation * _Nonnull operation);

@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface DataOperation : NSOperation

- (instancetype)initWithDB:(FMDatabase *)theDatabase NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) id delegate;
@property (nonatomic) SEL selector;
@property (nonatomic, copy, nullable) DataOperationCallback callback;
@property (nonatomic, assign) BOOL runningInDataOperationQueue, success;
@property (nonatomic, strong) NSMutableDictionary *response;
@property (nonatomic, strong) NSMutableDictionary *arguments;

- (BOOL)operation;
- (void)checkSafety;

- (void)startTransaction;
- (void)endTransaction;

- (void)sendCallback;

- (void)addQuery:(NSString *)query
       arguments:(NSArray * _Nullable)args;

- (NSString *_Nullable)getQueryValue:(NSString *)query
                           arguments:(NSArray * _Nullable)args;

- (NSDictionary *_Nullable)getQueryRow:(NSString *)query
                             arguments:(NSArray *)args;

- (NSMutableDictionary *_Nullable)getQuery:(NSString *)query
                                 arguments:(NSArray * _Nullable)args
                                     merge:(NSMutableDictionary *_Nullable* _Nullable)merge
                           variableKeyPath:(NSString *)variableKeyPath;

- (NSMutableDictionary *_Nullable)getQuery:(NSString *)query
                                 arguments:(NSArray * _Nullable)args
                                     merge:(NSMutableDictionary *_Nullable* _Nullable)merge
                           variableKeyPath:(NSString *)variableKeyPath
                                     value:(NSString *)valueKey;

@end

NS_ASSUME_NONNULL_END
