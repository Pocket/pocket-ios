//
//  PKTListenCoverFlowItemCollectionViewCell.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListenItem.h"

@interface PKTListenCoverFlowItemCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic, readwrite, strong) PKTKusari<id<PKTListenItem>> *kusari;

@end
