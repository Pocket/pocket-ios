//
//  PKTHTMLParser.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 11/26/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

#import "PKTKusari.h"
#import "PKTListenItem.h"
#import "PKTArticleContent.h"

@class PKTTextUnit;
@class PKTKusari;
@class PKTItem;

NS_ASSUME_NONNULL_BEGIN

/**
 PKTHTMLParser is a simple parser class used for parsing article HTML into a PKTKusari<PKTTextUnit> tree.
 */

@interface PKTHTMLParser : NSObject

/// Parse an HTML string into a kusari containing text unit representations.

@property (nonatomic, readonly, copy, nonnull, class) PKTKusari<PKTTextUnit<PKTListDiffable>*> * (^parse)(NSURL *baseURL, NSString *HTML);

@end

NS_ASSUME_NONNULL_END
