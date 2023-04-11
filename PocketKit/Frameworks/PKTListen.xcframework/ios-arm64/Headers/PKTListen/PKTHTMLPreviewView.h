//
//  PKTHTMLPreviewView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/28/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import UIKit;

#import "PKTKusari.h"
#import "PKTListenItem.h"

NS_ASSUME_NONNULL_BEGIN

/** PKTHTMLPreviewView is a developer-facing view for visualizing a PKTKusari<PKTTextUnit*> HTML tree. */

@interface PKTHTMLPreviewView : UIView

@property (nonatomic, readwrite, strong, nullable) PKTKusari<id<PKTListenItem>> *kusari;

@end

NS_ASSUME_NONNULL_END
