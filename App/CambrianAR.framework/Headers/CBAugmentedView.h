//
//  CBAugmentedView.h
//  CambrianAR
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "CBAugmentedScene.h"

@class CBTexture;

NS_ASSUME_NONNULL_BEGIN

@interface CBAugmentedView : UIView

@property (nonatomic, strong, nullable) CBAugmentedScene *scene;

@property (nonatomic, assign) CBToolMode toolMode;

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, strong) dispatch_queue_t cb_queue;

@property (nonatomic, readonly) BOOL isLive;
@property (nonatomic, assign) BOOL isAREnabled;

+ (CBAugmentedView *) getInstance;

- (void) captureCurrentState;

- (BOOL) startRunning;
- (BOOL) stopRunning;

- (void) clearAll;

@property (nonatomic, readonly) int undoSize;
- (void) undo;

@property (nonatomic, readonly) int redoSize;
- (void) redo;

@end

NS_ASSUME_NONNULL_END
