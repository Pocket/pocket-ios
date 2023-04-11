//
//  PKTLetterPressView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/17/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import UIKit;

#import "PKTKusari+PKTListen.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(int64_t, PKTLetterPressPin) {
    PKTLetterPressPinNorth                 = 1 << 1,
    PKTLetterPressPinSouth                 = 1 << 2,
    PKTLetterPressPinEast                  = 1 << 3,
    PKTLetterPressPinWest                  = 1 << 4,
    PKTLetterPressPinSpecialTall           = 1 << 5,
    PKTLetterPressPinSpecialWideWest       = 1 << 6,
    PKTLetterPressPinSpecialWideEast       = 1 << 7,
};

@interface PKTLetterPressView : UIImageView

@property (nullable, nonatomic, readwrite, strong) PKTKusari<id<PKTListenItem>> *kusari;

@end

NS_ASSUME_NONNULL_END
