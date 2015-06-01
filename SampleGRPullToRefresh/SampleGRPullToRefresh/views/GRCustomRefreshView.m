//
//  GRCustomRefreshView.m
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 06/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//

#import "GRCustomRefreshView.h"
#import "UIColor+ColorUtils.h"
#define CreateCAMediaTimingFunction(c1,c2,c3,c4) [CAMediaTimingFunction functionWithControlPoints:c1 :c2 :c3 :c4]


@implementation GRCustomRefreshView
@synthesize progressTintColor = _progressTintColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.frameRate = 1.f/60.f;
    
    
    [self initProgressTintColor];
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = self.progressTintColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = 6.f;
    _progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.frame = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:CGRectGetMidX(self.bounds) startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    [self.layer addSublayer:_progressLayer];
    _progressLayer.transform = CATransform3DMakeScale(0.5f, 0.5f, 1);
    self.animationState = GRMiniLoaderAnimationStateFirst;
    self.isAnimating = NO;
}
-(void)initColors{
    self.colors =  [NSMutableArray array];
    for(NSString *colorString in @[@"da5254", @"ea9437", @"9c65e0", @"e8dc75", @"f3a1ee", @"6bcbe3", @"4fa971", @"6e674f", @"ead6c2"]){
        [self.colors addObject:[UIColor colorWithHex:colorString]];
    }
    
}


-(void)initProgressTintColor{
    if([self.colors count] == 0){
        [self initColors];
    }
    int index = (arc4random() % [self.colors count]);
    
    UIColor *colorChoose = [self.colors objectAtIndex:index];
    if([colorChoose isEqual:self.progressTintColor]){
        index = (index+1)%self.colors.count;
        colorChoose = [self.colors objectAtIndex:index];
    }
    [self.colors removeObjectAtIndex:index];
    self.progressTintColor = colorChoose;
}





-(void)setTintColor:(UIColor *)tintColor{
    [super setTintColor:tintColor];
    self.progressLayer.strokeColor = tintColor.CGColor;
    [self setNeedsLayout];
}

#pragma mark - AGRessors

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress > 0) {
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = self.progress == 0 ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            self.progressLayer.strokeEnd = progress;
            [self.progressLayer addAnimation:animation forKey:@"animation"];
            
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    
    _progress = progress;
}





-(void)startRefreshing{
    [super startRefreshing];
    [self startAnimatingLoaderView];
}

-(void)endRefreshing{
    [super endRefreshing];
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    [self setProgress:0 animated:YES];
}


-(void)startAnimatingLoaderView{
    _progressLayer.strokeStart = 0;

    if(!self.isAnimating){
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            _progressLayer.strokeStart = 0;
            _progressLayer.strokeEnd = 1;
            [_progressLayer removeAllAnimations];
            [self updateAnimation];
        }];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(self.progress);
        animation.toValue = @(1);
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        animation.duration = 0.25f;
        [_progressLayer addAnimation:animation forKey:@"animation"];
        [CATransaction commit];
        self.isAnimating = YES;
        self.shouldEndAnimating = NO;
    }

}
-(void)animateProgressLayerWithRatio:(CGFloat)ratio{
    self.alpha = ratio;
    if (ratio > 0.f && ratio < 1.f) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.progressLayer.strokeEnd = ratio;
        [CATransaction commit];
    } else if(ratio <= 0.f){
        self.progressLayer.strokeEnd = 0.f;
    }
    else if(ratio >= 1.f){
        self.progressLayer.strokeEnd = 1.f;
    }
}
-(void)pullToRefreshTriggeringWithRatio:(CGFloat)ratio{
    [self animateProgressLayerWithRatio:ratio];
    
}

-(void)infiniteScrollingTriggeringWithRatio:(CGFloat)ratio{
    [self animateProgressLayerWithRatio:ratio];
}
- (void)tick:(NSTimer *)timer {
    CGFloat progress = self.progress;
        [self setProgress:(progress <= 1.00f ? progress + 1.f/60.f : 0.0f) animated:YES];
}

-(void)updateAnimation{
    
    switch (self.animationState) {
        case GRMiniLoaderAnimationStateFirst:{
            [self firstAnimation];
            break;
        }
        case GRMiniLoaderAnimationStateSecond:{
            [self secondAnimation];
            break;
        }
        case GRMiniLoaderAnimationStateThird:{
            [self thirdAnimation];
            break;
        }
        case GRMiniLoaderAnimationStateFourth:{
            break;
        }
        default:break;
    }
}



-(void)firstAnimation{
    CABasicAnimation *firstAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    firstAnimation.fromValue = @0;
    firstAnimation.toValue = @1;
    firstAnimation.duration = 0.75f;
    firstAnimation.removedOnCompletion = NO;
    firstAnimation.fillMode = kCAFillModeForwards;
    firstAnimation.delegate = self;
    firstAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
    [self.progressLayer addAnimation:firstAnimation forKey:@"animation"];

}

-(void)secondAnimation{
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeAnimation.fromValue = @0;
    strokeAnimation.toValue = @1;
    strokeAnimation.duration = 0.5f;
    strokeAnimation.removedOnCompletion = NO;
    strokeAnimation.fillMode = kCAFillModeForwards;
    //strokeAnimation.delegate = self;
    strokeAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
    strokeAnimation.beginTime = 0.5f;

    
    //[self.progressLayer addAnimation:strokeAnimation forKey:@"animation"];

    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @0;
    rotateAnimation.toValue = @(M_PI+M_PI_2);
    rotateAnimation.duration = 0.5f;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    //rotateAnimation.delegate = self;
    rotateAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
    rotateAnimation.beginTime = 0.75f;
    
    //[self.progressLayer addAnimation:rotateAnimation forKey:@"animation2"];
    
    
    CAAnimationGroup *secondAnimation = [CAAnimationGroup animation];
    secondAnimation.removedOnCompletion = NO;
    secondAnimation.fillMode = kCAFillModeForwards;
    //secondAnimation.duration = 0.5f;
    secondAnimation.duration = 1.25f;
    secondAnimation.animations = @[strokeAnimation,rotateAnimation];
    secondAnimation.delegate = self;
    
    [self.progressLayer addAnimation:secondAnimation forKey:@"animation"];
}
-(void)thirdAnimation{
    [self initProgressTintColor];
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.fromValue = @0;
    strokeAnimation.toValue = @1;
    strokeAnimation.duration = 0.75f;
    strokeAnimation.removedOnCompletion = NO;
    strokeAnimation.fillMode = kCAFillModeForwards;
    //strokeAnimation.delegate = self;
    strokeAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
    
    
    //[self.progressLayer addAnimation:strokeAnimation forKey:@"animation"];
    
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(M_PI+M_PI_2);
    rotateAnimation.toValue = @(2*M_PI);
    rotateAnimation.duration = 0.75f;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    //rotateAnimation.delegate = self;
    rotateAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
    
    //[self.progressLayer addAnimation:rotateAnimation forKey:@"animation2"];
    
    
    CAAnimationGroup *thirdAnimation = [CAAnimationGroup animation];
    thirdAnimation.removedOnCompletion = NO;
    thirdAnimation.fillMode = kCAFillModeForwards;
    //secondAnimation.duration = 0.5f;
    thirdAnimation.duration = 1.25f;
    if(self.shouldEndAnimating){
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.f)];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.f, 1.f, 1.f)];
        scaleAnimation.duration = 0.18f;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.beginTime = 0.57f;
        scaleAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @(1.f);
        alphaAnimation.toValue = @(0.f);
        alphaAnimation.duration = 0.18f;
        alphaAnimation.removedOnCompletion = NO;
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.beginTime = 0.57f;
        alphaAnimation.timingFunction = CreateCAMediaTimingFunction(0.840, 0.005, 0.085, 1.000);
        
        
        thirdAnimation.animations = @[strokeAnimation,rotateAnimation,scaleAnimation, alphaAnimation];

    }
    else{
        thirdAnimation.animations = @[strokeAnimation,rotateAnimation];
    }
    thirdAnimation.delegate = self;
    
    [self.progressLayer addAnimation:thirdAnimation forKey:@"animation"];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if([anim isKindOfClass:[CABasicAnimation class]] && flag && self.animationState == GRMiniLoaderAnimationStateFirst){
        CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
        _progressLayer.strokeEnd = [basicAnimation.toValue floatValue];
        [_progressLayer removeAllAnimations];
        self.animationState = GRMiniLoaderAnimationStateSecond;
        [self updateAnimation];
    }
    else if([anim isKindOfClass:[CAAnimationGroup class]] && flag){
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)anim;
        switch(self.animationState){
            case GRMiniLoaderAnimationStateFirst:{
                break;
            }
            case GRMiniLoaderAnimationStateSecond:{
                _progressLayer.strokeStart = 0;
                _progressLayer.strokeEnd = 0;

                CABasicAnimation *rotateAnimation = animationGroup.animations[1];
                _progressLayer.transform = CATransform3DConcat(_progressLayer.transform, CATransform3DMakeRotation([rotateAnimation.toValue doubleValue], 0, 0, 1.f));

                [_progressLayer removeAllAnimations];
                self.animationState = GRMiniLoaderAnimationStateThird;
                [self updateAnimation];

                break;
            }
            case GRMiniLoaderAnimationStateThird:{
                _progressLayer.strokeStart = 0;
                _progressLayer.transform = CATransform3DMakeScale(0.5f, 0.5f, 1.f);

                if(self.shouldEndAnimating){
                    _progressLayer.strokeEnd = 0;
                    
                    [_progressLayer removeAllAnimations];
                    [self initProgressTintColor];

                    self.animationState = GRMiniLoaderAnimationStateSecond;
                    self.isAnimating = NO;
                    self.shouldEndAnimating = NO;
                    [self endRefreshing];
                    
                }
                else{
                    _progressLayer.strokeEnd = 1;

                    [_progressLayer removeAllAnimations];
                    self.animationState = GRMiniLoaderAnimationStateSecond;

                    [self updateAnimation];

                }
                

                break;
            }
            case GRMiniLoaderAnimationStateFourth:{
                break;
            }
            default:break;
                
        }
    }
}


- (UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(tintColor)]) {
        return self.tintColor;
    }
#endif
    return _progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = progressTintColor;
        return;
    }
#endif
    _progressTintColor = progressTintColor;
    self.progressLayer.strokeColor = progressTintColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Other

#ifdef __IPHONE_7_0
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
    [self setNeedsDisplay];
}
#endif
@end
