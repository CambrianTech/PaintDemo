//
//  CBRemodelingView.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAugmentedView.h"
#import "CBRemodelingTypes.h"
#import "CBRemodelingScene.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CBRemodelingViewDelegate <NSObject>
@optional
- (void) historyChanged:(CBUndoChange)change assetID:(NSString *)assetID userData:(NSDictionary<NSString*, NSString*> *)userData forward:(BOOL)forward;
@end

@interface CBRemodelingView : CBAugmentedView

@property (weak, nonatomic, nullable) id<CBRemodelingViewDelegate> delegate;

@property (nonatomic, strong, nonnull) CBRemodelingScene *scene;


@end

NS_ASSUME_NONNULL_END
