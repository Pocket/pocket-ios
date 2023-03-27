//
//  PKTAPIRequestBuild.h
//  RIL
//
//  Created by Nicholas Zeltzer on 4/1/17.
//
//

#import "PKTSharedEnums.h"

NS_ASSUME_NONNULL_BEGIN

/**
 PKTAPIRequestBuild exposes a functional interface to working with APIRequest and DataOperation instances.
 
 In either case, an 'endpoint' or 'operation' is created with either PKTAPIEndPointCreate, or 
 PKTAPIOperationCreate. The returned functions can be used to create asynchrnous tasks, the results of which 
 will be returned as a PKTAPITaskResult object.
 
 Sample usage:
 
 PKTAPIEndPoint endPoint = PKTAPIEndPointCreate(@"get", 
                                                nil, 
                                                PKTAPITaskAuthenticationRequired, 
                                                NSURLRequestUseProtocolCachePolicy,
                                                ReadItLaterNotifyOnErrorNever);
 
 This endpoint function can be used to generate individual tasks. Each vended task is a function that 
 conforms to all of the configuration parameters that were passed into the endpoint.
 
 // Create a reusable task type.
 PKTAPITask task = endPoint(<some_parser>, <some_completion_block>);
 
 // Execute a specific series of tasks.
 task(@{ @"search" : @"technology", @"offset" : @0, @"count" : @25 });
 
 task(@{ @"search" : @"politics", @"offset" : @25, @"count" : @15 });
 
 task(@{ @"search" : @"games", @"offset" : @0, @"count" : @100 });
 
 */

@class PKTAPITaskResult;
@class PKTJSONParser;
@class DataOperation;

#pragma mark - PKTAPIRequestBuild 

typedef NS_ENUM(NSInteger, PKTAPITaskAuthentication) {
    PKTAPITaskAuthenticationUndefined,
    PKTAPITaskAuthenticationNotRequired,
    PKTAPITaskAuthenticationRequired,
};

typedef NS_ENUM(NSInteger, PKTAPITaskErrorReport) {
    PKTAPITaskErrorReportNever = 0,
    PKTAPITaskErrorReportAlways,
    PKTAPITaskErrorReportMajor,   // only for errors like maintance or rate limit
};

UIKIT_EXTERN NSString * const kPKTAPITaskRequestTimeOutDuration;

typedef id<NSObject> _Nonnull (^PKTAPIOperationResponseMutation)(NSDictionary *parameters, id<NSObject> responseObject);

typedef void (^PKTAPITaskCancel)(void);
typedef void (^PKTAPITaskDidFinish)(PKTAPITaskResult *_Nonnull result);
typedef PKTAPITaskCancel _Nonnull (^PKTAPITask)(NSDictionary *_Nullable parameters, NSDictionary *_Nullable context);
typedef PKTAPITask _Nonnull (^PKTAPIEndPoint)(PKTJSONParser *_Nullable parser, PKTAPITaskDidFinish _Nonnull completion);
typedef PKTAPITask _Nonnull (^PKTAPIOperation)(PKTJSONParser *_Nullable parser, PKTAPITaskDidFinish _Nonnull completion);

@interface PKTAPIRequestBuild : NSObject

/** @return A new PKTAPIEndPoint block that can be used to generate APIRequest-backed tasks. */
PKTAPIEndPoint PKTAPIEndPointCreate(NSString *_Nonnull path,
                                    NSDictionary *_Nullable parameters,
                                    PKTAPITaskAuthentication auth,
                                    NSURLRequestCachePolicy cache,
                                    PKTAPITaskErrorReport report);

/** @return A new PKTAPIOperation block that can be used to generate DataOperation-backed tasks. */
PKTAPIOperation PKTAPIOperationCreate(Class operationClass,
                                      NSDictionary *_Nullable parameters,
                                      PKTAPIOperationResponseMutation _Nullable mutation);

/** Placeholder for PKTAutoBind experiment. */
id PKTAutoBindExperimentProduce(Class klass,
                                NSDictionary *_Nullable rawValue,
                                NSDictionary *_Nullable mapping);

@end

#define PKTAutoBinding(klass, rawValue, map) PKTAutoBindExperimentProduce([klass class], PKTDynamicCast(rawValue, NSDictionary), PKTDynamicCast(map, NSDictionary))

#pragma mark - PKTAPITaskResult

@class PKTJSONParser;

/**
 PKTAPITaskResult wraps the a APIRequest or DataOperation into an easily-queried unit that exposes all 
 the original task parameters; raw task results, and response data; and provides an external interface to
 an internal parser object that can be used to quickly query the response data.
 */

@interface PKTAPITaskResult : NSObject {
@public NSError *_Nullable _error;
@public PKTJSONParser *_Nullable _parser;

}

/** @return the underlying NSURLRequest. 
 @note This value will be nil for tasks created from DataOperations */
@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;
/** @return the underlying DataOperation. 
 @note This value will be nil for tasks created from APIRequests */
@property (nullable, nonatomic, readonly, strong) DataOperation *operation;
/** @return the underlying NSHTTPURLResponse. 
 @note This value will be nil for tasks created from DataOperations */
@property (nullable, nonatomic, readonly, strong) NSHTTPURLResponse *response;
/** @return the underlying error, if any. */
@property (nullable, nonatomic, readonly, strong) NSError *error;
/** @return the underlying response data. 
 @note This value will be nil for tasks created from DataOperations */
@property (nullable, nonatomic, readonly, strong) NSData *responseData;
/** @return the underlying response data interpreted as a UTF8String.
 @note This value will be nil for tasks created from DataOperations */
@property (nullable, nonatomic, readonly, strong) NSString *_Nullable (^responseString)(NSStringEncoding encoding);
/** @return the original task parameters.
 @note For DataOperation-backed tasks, this will be the request parameters as provided. For APIRequest-backed tasks, this will also include the actual HTTP request parameters, as exposed in the HTTP body. */
@property (nullable, nonatomic, readonly, strong) NSDictionary *requestParameters;
/**
 @return the product of applying the parser provided during task creation to the response object.
 @note DataOperation-backed tasks are not guaranteed to produce JSON-compatible objects; parsability cannot be guaranteed. */
@property (nullable, nonatomic, readonly, strong) id<NSObject> parsedObject;

/**
 @return NSDictionary of additional context that was provided when the task was executed.
 */
@property (nullable, nonatomic, readonly, strong) NSDictionary *context;

/** Return the result of evaluating the response data against the provided JSONPath expression.
 @note DataOperation-backed tasks are not guaranteed to produce JSON-compatible objects; parsability cannot be guaranteed. */

- (NSArray<id<NSObject>>*_Nullable)evaluateData:(NSString *)expression;

/** Return the result of evaluating the response object against the provided JSONPath expression.
 @note DataOperation-backed tasks are not guaranteed to produce JSON-compatible objects; parsability cannot be guaranteed. */
- (NSArray<id<NSObject>>*_Nullable)evaluateObject:(NSString *)expression;

@end

#pragma mark PKTAPITaskResult+PKTReaderAnnotations

@interface PKTAPITaskResult (PKTReaderAnnotations)

- (NSDictionary *_Nullable)JSONResponse;

@end

#pragma mark - PKTEndpoint

/** Object-Oriented wrapper class for PKTAPIEndpointCreate(). */

@interface PKTEndpoint : NSObject

@property (nonatomic, readonly, copy, nonnull) PKTAPITask (^newTask)(PKTJSONParser *parser, PKTAPITaskDidFinish completion);

+ (instancetype)endpoint:(NSString *_Nullable)path
              parameters:(NSDictionary *_Nullable)defaultParameters
          authentication:(PKTAPITaskAuthentication)authentication
             errorPolicy:(PKTAPITaskErrorReport)errorPolicy
             cachePolicy:(NSURLRequestCachePolicy)cachePolicy;

- (PKTAPITask)newTask:(nullable PKTJSONParser *)parser
           completion:(nonnull void(^)(PKTAPITaskResult *_Nonnull result))completion;

- (PKTAPITask)simpleTask:(nonnull void(^)(PKTAPITaskResult *_Nonnull result))completion;

@end

#pragma mark - PKTURLCache

/**
 PKTURLCache is an NSURLCache subclass that is used internally by PKTAPIRequestBuild to provide optional
 NSURLCaching capabilities to network requests.
 */

@interface PKTURLCache : NSURLCache

+ (instancetype)sharedURLCache;

/** Store a APIRequest-backed APITaskResult in the cache
 @param result An APIRequest-backed APITaskResult
 @param request The NSURLRequest that shoud be used as a unique key to store and retrieve this task.
 @param policy The NSURLCacheStoragePolicy to apply in evaluating whether or not a task result is cachable.
 @note The APIRequest-backed tasks generated by PKTAPIRequestEndPoint do not use the default global NSURLCache object.
 */

+ (void)storeTaskResult:(PKTAPITaskResult *)result
             forRequest:(NSURLRequest *)request
                 policy:(NSURLCacheStoragePolicy)policy;

/** @return a previously-cached APIRequest-backed APITastResult object. 
 @param request the NSURLRequest that uniquely identifies a cached task result*/

+ (PKTAPITaskResult *_Nullable)cachedTaskResultForRequest:(NSURLRequest *)request;

/** Remove a previously-cached APIRequest-backed APITastResult object.
 @param request the NSURLRequest that uniquely identifies a cached task result*/

+ (void)removeCachedTaskResultForRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
