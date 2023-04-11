//
//  PKTAPIRequestBuildPrivate.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 9/3/19.
//  Copyright © 2019 Pocket. All rights reserved.
//

#import "PKTAPIRequestBuild.h"

@interface PKTAPITaskResult() {
@public NSURLRequest *_Nullable _request;
@public DataOperation *_Nullable _operation;
@public NSHTTPURLResponse *_Nullable _response;
@public NSData *_Nullable _responseData;
@public NSDictionary *_Nullable _requestParameters;
@public id<NSObject> _Nullable _parsedObject;
@public NSDictionary *_context;
}

@property (readwrite, nullable) NSURLRequest *request;
@property (readwrite, nullable) NSHTTPURLResponse *response;
@property (readwrite, nullable) NSError *error;
@property (readwrite, nullable) NSData *responseData;
@property (readwrite, nullable) NSDictionary *requestParameters;
@property (readwrite, nullable) PKTJSONParser *parser;
@property (readwrite, nullable) NSDictionary *context;

#pragma mark - Private

@property (nonnull, nonatomic, readonly, strong) NSMutableDictionary <NSString*, NSArray<id<NSObject>>*> *dataExpressionResultsStore;
@property (nonnull, nonatomic, readonly, strong) NSMutableDictionary <NSString*, NSArray<id<NSObject>>*> *objectExpressionResultsStore;

@end
