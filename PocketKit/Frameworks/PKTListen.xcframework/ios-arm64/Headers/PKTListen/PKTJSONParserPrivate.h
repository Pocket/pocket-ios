//
//  PKTJSONParserPrivate.h
//  PKTJSONParser
//
//  Created by Nicholas Zeltzer on 3/20/17.
//  Copyright © 2017 Pocket. All rights reserved.
//

#ifndef PKTJSONParserPrivate_h
#define PKTJSONParserPrivate_h

#import "PKTJSONParser.h"
#import "PKTJSONPathLexer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTJSONParser (Private)

void PKTJSONPathWalk(PKTLList *path, id<NSObject> root, NSMutableArray<id<NSObject>> *_Nullable results);

NSArray * PKTJSONPathEvaluate(PKTLList *path, id<NSObject> root);

BOOL PKTLiteralMatchesPath(PKTLList *pathLiteral, PKTLList *pathExpression);

id<NSObject> PKTJSONPathParseF(id<NSObject> object, PKTJSONPathTransformationStore *store);

- (BOOL)setTransformation:(PKTJSONPathTransformation)transformation forPath:(NSString *)path error:(NSError **)error;

- (PKTJSONPathTransformationStore *)transformationStore;

@end

NS_ASSUME_NONNULL_END

#endif /* PKTJSONParserPrivate_h */
