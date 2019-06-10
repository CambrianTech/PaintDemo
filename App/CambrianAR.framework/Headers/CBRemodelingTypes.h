//
//  CBRemodelingTypes.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#ifndef CBRemodelingTypes_h
#define CBRemodelingTypes_h

typedef NS_ENUM(NSInteger, CBPaintSheen) {
    CBPaintSheenFlat,
    CBPaintSheenMatte,
    CBPaintSheenEggshell,
    CBPaintSheenSatin,
    CBPaintSheenSemiGloss,
    CBPaintSheenHighGloss,
};

typedef NS_ENUM(NSInteger, CBLighting) {
    CBLightingNoAdjustment,
    CBLightingIncandescent,
    CBLightingLEDWarm,
    CBLightingLEDWhite,
    CBLightingFluorescent,
};

typedef NS_ENUM(NSInteger, CBUndoChange) {
    CBUndoChangePaintColor,
    CBUndoChangePaintSheen,
    CBUndoChangeMask,
};

#endif /* CBRemodelingTypes_h */
