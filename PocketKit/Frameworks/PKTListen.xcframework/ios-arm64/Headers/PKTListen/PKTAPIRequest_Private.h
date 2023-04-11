//
//  Header.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 7/27/18.
//

#import "PKTAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTAPIRequest ()

/// Current method for the request
@property (nonatomic, copy) NSString *method;

/// Parameterstring for the request
@property (nonatomic, copy)    NSString *params;

/// Determine if the user needs to be logged to be able to start this request
@property (nonatomic, assign) BOOL login;

/// Receiver of selector call if no callback is given and request finished
@property (nonatomic, weak) id delegate;

/// Selector called on delegate if no callback is given and request finished
@property (nonatomic, assign) SEL selector;

/// Final url string for the api request
@property (nonatomic, copy)    NSString *urlStr;

/// Response already parsed as json if the response was in json format
@property (nonatomic, strong) NSDictionary *JSONResponse;

/// Encoding for the data
@property (nonatomic, assign) NSStringEncoding encoding;

/// Request response headers
@property (nonatomic, strong) NSMutableDictionary *headers;

/// NSHTTPURLResponse of the request
@property (nonatomic, strong) NSHTTPURLResponse *URLResponse;

/// Set a unique identifier for the request
@property (nonatomic, copy, nullable) NSString *identifier;

/// Form data that should be send to the API via the request
@property (nonatomic, strong) PKTMultipartFormData *formData;

/// Request to make the API call
@property (nonatomic, strong) NSMutableURLRequest *request;

/// Received data of the request
@property (nonatomic, strong) NSMutableData *receivedData;

/// Session we use to make the request
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

/// Name of operation for error alert
@property (nonatomic, copy) NSString *operationNameForAlert;

/// Declare if the request should show error to the user in case an error happened
@property (nonatomic, assign) ReadItLaterNotifyOnError errorReporting;

/// Error that happened
@property (nonatomic, strong) NSError *error;

/// Pocket error message or error message if a generic error happened
@property (nonatomic, copy) NSString *errorMessage;

/// Pocket error code or error code if a generic error happened
@property (nonatomic, copy) NSString *errorCode;

/// Pocket error additional data for context of the error
@property (nonatomic, copy) NSString *errorData;

/// Declares if the error that happened was not a major system error
@property (nonatomic, assign) BOOL nonMajorSystemError;

@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString*, id> *parameters;

@end

NS_ASSUME_NONNULL_END
