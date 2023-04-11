//
//  PKTAPIRequest.h
//  RIL
//
//  Created by Nathan Weiner on 11/5/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTDataTask.h"
#import "PKTSharedEnums.h"

@class PKTMultipartFormData;
@class PKTAPIRequest;

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *kPKTForceGUID;

typedef void (^APIRequestCallback)(PKTAPIRequest * _Nullable request);

@interface PKTAPIRequest : NSObject

#pragma mark - Lifecycle

- (id)initAndStart:(NSString *)methodValue
             login:(BOOL)loginValue
            params:(NSString *)paramsValue
          delegate:(id _Nullable)delegateValue
          selector:(SEL _Nullable)selectorValue
              name:(NSString *)operationNameForAlertValue
    errorReporting:(ReadItLaterNotifyOnError)errorReportingValue;

- (id)initWithMethod:(NSString *)methodValue
               login:(BOOL)loginValue
              params:(NSString *)paramsValue
            delegate:(id _Nullable)delegateValue
            selector:(SEL _Nullable)selectorValue
                name:(NSString *)operationNameForAlertValue
      errorReporting:(ReadItLaterNotifyOnError)errorReportingValue;

- (id)initWithMethod:(NSString *)methodValue
               login:(BOOL)loginValue
              params:(NSString *)paramsValue
                name:(NSString *)operationNameForAlertValue
      errorReporting:(ReadItLaterNotifyOnError)errorReportingValue
            callback:(APIRequestCallback)callbackValue;

- (id)initWithMethod:(NSString *)methodValue
             timeOut:(NSTimeInterval)timeOut
               login:(BOOL)loginValue
              params:(NSString *)paramsValue
                name:(NSString *)operationNameForAlertValue
      errorReporting:(ReadItLaterNotifyOnError)errorReportingValue
            callback:(APIRequestCallback)callbackValue;

- (id)initWithMethod:(NSString *)methodValue
            formData:(PKTMultipartFormData *)dataValue
                name:(NSString *)operationNameForAlertValue
      errorReporting:(ReadItLaterNotifyOnError)errorReportingValue
            callback:(APIRequestCallback)callbackValue;

/**
 Creates a request the JSON data of the HTTP body will be set with the provided parameters data.
 
 @param methodValue The Pocket v3 endpoint name
 @param loginValue YES, if the request should include login credentials; otherwise, NO
 @param parameters An optional NSDictionary of JSON-compatible data to be set as the HTTP request body
 @param operationNameForAlertValue A name to be assigned to the underlying NSOperation, if any
 @param errorReportingValue The error reporting behavior to be used when the request completes
 @param callbackValue An APIRequestCallback completion block that will be executed when the request completes
 
 @note The parameters argument is exclusive: if provided, it will replace any default values (including authentication) that would have been handled automatically under the legacy API. Similarly, if nil is passed for the parameters value, the request will be constructed using legacy behavior, as form-encoded request, with
 authentication provided where necessary
 */

- (instancetype)initWithMethod:(NSString *)methodValue
                         login:(BOOL)loginValue
                    parameters:(NSDictionary<NSString*, id> * _Nullable)parameters
                          name:(NSString *)operationNameForAlertValue
                errorReporting:(ReadItLaterNotifyOnError)errorReportingValue
                      callback:(APIRequestCallback)callbackValue;

/// Current method of the request
@property (nonatomic, copy, readonly) NSString *method;

/// Determine if the user needs to be logged to be able to start this request
@property (nonatomic, assign, readonly) BOOL login;

/** The NSURLCache to assign to underlying requests.
 @default +[NSURLCache sharedCache]. */

@property (nonatomic, readwrite, strong) NSURLCache *URLCache;

/** The cache policy for the request.
 @default NSURLRequestReloadIgnoringLocalAndRemoteCacheData */

@property (nonatomic, assign, readwrite) NSURLRequestCachePolicy cachePolicy;

/// Set this value to YES if the request callback should be called on the main thread
@property (nonatomic, assign) BOOL callbackOnMain;

/// Set a callback if the request was succesfully executed
@property (nonatomic, copy) APIRequestCallback callback;

/// Current progress of the request for uploading data
@property (nonatomic, copy, nullable) PKTNetworkTaskDidUpdate progressCallback;

@property (nonatomic, assign) BOOL quiet;

/// Set to YES if we first have to try to get a GUID before the request should finish
@property (nonatomic, assign) BOOL forceGuid;

/// Define timout for NSURLConnection
@property (nonatomic, assign) NSTimeInterval timeout; // default 90s

/// Set specific information for the request
@property (nonatomic, strong, nullable) NSDictionary *info;

/// Response already parsed as json if the response was in json format
@property (nonatomic, strong, readonly) NSDictionary *JSONResponse;

/// NSHTTPURLResponse of the request
@property (nonatomic, strong, readonly)	NSHTTPURLResponse *URLResponse;

/// NSURL respresentation of the API request with the complete parameter string
/// @note The parameter string is not populated until after a request is begun, making this method useful only for debugging requests that have been sent.
@property (nonatomic, strong, readonly, nullable) NSURL *APIRequestURL;

#pragma mark - Errors

/// Error that happened
@property (nonatomic, strong, readonly, nullable) NSError *error;

/// Pocket error message or error message if a generic error happened
@property (nonatomic, copy, readonly) NSString *errorMessage;

/// Pocket error code or error code if a generic error happened
@property (nonatomic, copy, readonly) NSString *errorCode;

/// Pocket error additional data for context of the error
@property (nonatomic, copy, readonly) NSString *errorData;

// Define if the error should be presented to the user or not if an error happened
@property (nonatomic, assign, readonly)	ReadItLaterNotifyOnError errorReporting;

#pragma mark - States

/// Determines if the APIRequest was successful
@property (nonatomic, assign) BOOL success;

/// Determines if the APIRequest was cancelled
@property (nonatomic, assign) BOOL cancelled;

/// Determines if the APIRequest was finished
@property (nonatomic, assign) BOOL finished;

#pragma mark - Form Data

+ (PKTMultipartFormData *)loggedInFormData;

#pragma mark - Linking

+ (instancetype)requestForIdentifier:(NSString *)identifier;
- (void)linkWithIdentifier:(NSString *)identifier;
- (void)unlinkIdentifier;

#pragma mark - Start

- (void)start;

#pragma mark - Finishing

- (void)finish:(BOOL)finished;

#pragma mark - Errors

- (void)handleError;
- (void)forceHandleError;

#pragma mark - Cancel

- (void)cancel;

#pragma mark - Subclass

- (void)buildRequest;

- (BOOL)forceAccessTokenRegeneration;

- (void)hideActivityForKey:(NSString *)key;

- (void)showActivityForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
