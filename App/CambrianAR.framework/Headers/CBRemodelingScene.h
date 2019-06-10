//
//  CBRemodelingScene.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAugmentedScene.h"

#import "CBRemodelingPaint.h"
#import "CBRemodelingFloor.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBRemodelingScene : CBAugmentedScene

@property (strong, nonatomic, nullable) CBRemodelingPaint *selectedPaint;
@property (strong, nonatomic, nullable) CBRemodelingFloor *selectedFloor;

@property (readonly, nonatomic) BOOL isMasked;

@end

NS_ASSUME_NONNULL_END
