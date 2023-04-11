//
//  PKTModelAnnotationsConformance.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 3/10/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#ifndef PKTModelAnnotationsConformance_h
#define PKTModelAnnotationsConformance_h

#import "PKTHandyMacros.h"

@class Action;

#ifndef PKTAnnotationsEnabled
#define PKTAnnotationsEnabled
#endif

NS_ASSUME_NONNULL_BEGIN;

@protocol PKTListDataOperationAnnotationsConformance <NSObject>

- (void)saveAnnotations:(NSNumber *)uniqueIDNo
                   data:(NSDictionary<NSString*,id>*)userInfo
                replace:(BOOL)replace;

- (void)insertAnnotationFromAction:(Action *)action;

- (void)deleteAnnotationFromAction:(Action *)action;

@end

@protocol PKTItemAnnotationsConformance <NSObject>

@property (nullable, nonatomic, readonly) NSArray<NSDictionary*> *highlightAnnotationsJSONObjects;

- (NSArray<NSDictionary*> *)rawHighlightAnnotations:(NSDictionary<NSString*, id> *)userInfo;

- (void)addAnnotationFromJSON:(NSDictionary *_Nonnull)annotationJSON broadcast:(BOOL)broadcast;

- (void)removeAnnotationWithID:(NSString *_Nonnull)annotationID broadcast:(BOOL)broadcast;

@end

NS_ASSUME_NONNULL_END;

#endif /* PKTModelAnnotationsConformance_h */
