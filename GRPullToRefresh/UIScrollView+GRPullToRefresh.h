//
//  UIScrollView+GRPullToRefresh.h
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 05/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRRefreshView.h"


@protocol GRPullToRefreshDelegate <UIScrollViewDelegate>

-(void)pullToRefreshTriggeredWithRatio:(CGFloat)ratio;
-(void)pullToRefreshDidStartLoading;
-(void)pullToRefreshDidStoppedLoading;



@end;
@interface UIScrollView (GRPullToRefresh)

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler refreshView:(GRRefreshView *)pullToRefreshView;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) GRRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end



