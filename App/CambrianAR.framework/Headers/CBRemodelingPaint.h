//
//  CBRemodelingPaint.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAugmentedAsset.h"
#import "CBRemodelingTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBRemodelingPaint : CBAugmentedAsset

@property (nonatomic, assign) CBPaintSheen sheen;
@property (nonatomic, strong, nonnull) UIColor* color;

@end

NS_ASSUME_NONNULL_END
