//
//  PKTAppearanceMask.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 7/11/18.
//

@import Foundation;

#ifndef PKTAppearanceMask_h
#define PKTAppearanceMask_h

typedef NS_OPTIONS(int64_t, PKTTextTheme) {
    PKTTextThemeUndefined         = 0,
    PKTTextThemeDay               = 1 << 5,
    PKTTextThemeNight             = 1 << 6,
    PKTTextThemeSepia             = 1 << 7,
};

typedef NS_OPTIONS(int64_t, PKTAppTheme) {
    PKTAppThemeUndefined           = 0,
    PKTAppThemeLight               = 1 << 1,
    PKTAppThemeDark                = 1 << 2,
    PKTAppThemeBlack               = 1 << 3,
    PKTAppThemeSepia               = 1 << 4,
};

typedef NS_OPTIONS(int64_t, PKTAppearanceMask) {
    PKTAppearanceMaskUndefined                = (PKTTextThemeUndefined|PKTAppThemeUndefined),
    PKTAppearanceMask1LightSepia              = (PKTAppThemeLight|PKTTextThemeSepia),
    PKTAppearanceMask1LightDay                = (PKTAppThemeLight|PKTTextThemeDay),
    PKTAppearanceMask1DarkNight               = (PKTAppThemeDark|PKTTextThemeNight),
    PKTAppearanceMask1BlackNight              = (PKTAppThemeBlack|PKTTextThemeNight),
    PKTAppearanceMask1SepiaSepia              = (PKTAppThemeSepia|PKTTextThemeSepia),
    
    PKTAppearancePackageSepia                 = (PKTAppearanceMask1SepiaSepia|PKTAppearanceMask1SepiaSepia << 8),
    PKTAppearancePackageLight                 = (PKTAppearanceMask1LightDay|PKTAppearanceMask1LightDay << 8),
    PKTAppearancePackageDark                  = (PKTAppearanceMask1DarkNight|PKTAppearanceMask1DarkNight << 8),
    PKTAppearancePackageBlack                 = (PKTAppearanceMask1BlackNight|PKTAppearanceMask1BlackNight << 8),
    PKTAppearancePackageAutoDark              = (PKTAppearanceMask1LightDay|PKTAppearanceMask1DarkNight << 8),
    PKTAppearancePackageAutoBlack             = (PKTAppearanceMask1LightDay|PKTAppearanceMask1BlackNight << 8),
};

// Pack or unpack 8 bits of appearance data at a given index.
PKTAppearanceMask PKTAppearanceMaskUnpack(PKTAppearanceMask options, NSInteger idx);
PKTAppearanceMask PKTAppearanceMaskPack(PKTAppearanceMask options, PKTAppearanceMask pack, NSInteger idx);

// Erase 8 bits of mask data at a given offset.
PKTAppearanceMask PKTAppearanceMaskErase(PKTAppearanceMask options, NSInteger idx);

// Validate that the specific value is present in a packed mask at a specific index.
BOOL PKTAppearanceMaskInclude(PKTAppearanceMask package, PKTAppearanceMask element, NSInteger idx);

// Extract the PKTTextTheme or PKTAppTheme values
PKTTextTheme PKTAppearanceTextTheme(PKTAppearanceMask options);
PKTAppTheme PKTAppearanceAppTheme(PKTAppearanceMask options);

// Treat the mask as a stack, allowing us to push up to 64 bits of information
PKTAppearanceMask PKTAppearanceMaskPush(PKTAppearanceMask mask, PKTAppearanceMask push);
PKTAppearanceMask PKTAppearanceMaskPop(PKTAppearanceMask *_Nonnull mask);

NSString *_Nonnull PKTAppearanceTextThemeDescription(PKTAppearanceMask options);
NSString *_Nonnull PKTAppearanceAppThemeDescription(PKTAppearanceMask options);

// For testing purposes, a quick inversion between "light" and "dark" themes
PKTAppearanceMask PKTAppearanceInvert(PKTAppearanceMask options);

NSString *_Nonnull PKTAppearanceMaskDescription(PKTAppearanceMask options);


#endif /* PKTAppearanceMask_h */
