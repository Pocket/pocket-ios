//
//  PKTListenHeaderSection.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/17/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "IGListKit/IGListKit.h"

#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenHeaderSection : IGListSectionController

@property (nullable, nonatomic, readonly, strong) PKTKusari<NSString<PKTListDiffable>*>* kusari;

@end

NS_ASSUME_NONNULL_END
