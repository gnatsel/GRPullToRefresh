//
//  GRCustomRefreshView.h
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 06/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRRefreshView.h"

typedef NS_ENUM(int, GRMiniLoaderAnimationState) {
    GRMiniLoaderAnimationStateFirst,
    GRMiniLoaderAnimationStateSecond,
    GRMiniLoaderAnimationStateThird
};
@interface GRCustomRefreshView : GRRefreshView

/**
 The progress of the circular view. Only valid for values between `0` and `1`.
 
 The default is `0`.
 */
@property (nonatomic) float progress;



/**
 Set the progress of the circular view in an animated manner. Only valid for values between `0` and `1`.
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic, assign) GRMiniLoaderAnimationState animationState;
@property (nonatomic, assign) CGFloat frameRate;
@property (nonatomic, assign) BOOL isAnimating;


/**
 A tintColor replacement for pre-iOS7 SDK versions. On iOS7 and higher use `tintColor` for setting this.
 
 The default is the parent view's `tintColor` or a black color on versions lower than iOS7.
 */
@property (nonatomic, strong) UIColor *progressTintColor;

@property (nonatomic, copy) void (^endRefreshAnimationCompletionHandler)(void);



- (void)addEndRefreshAnimationCompletionHandler:(void (^)(void))completionHandler;
@end
