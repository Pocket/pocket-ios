//
//  Item+PKTListDiffable.h
//  RIL
//
//  Created by Nicholas Zeltzer on 3/28/17.
//
//

#import "PKTKusari.h"
#import "PKTItem.h"

@interface PKTItem (PKTListDiffable) <PKTListDiffable>

- (BOOL)isEqualToDiffableObject:(id<PKTListDiffable>)object;

- (id<NSObject>)diffIdentifier;

@end
