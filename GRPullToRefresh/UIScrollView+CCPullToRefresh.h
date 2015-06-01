//
//  UIScrollView+CCPullToRefresh.h
//  OPIColorChat
//
//  Created by Olivier Lestang [DAN-PARIS] on 05/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRefreshView.h"


@protocol CCPullToRefreshDelegate <UIScrollViewDelegate>

-(void)pullToRefreshTriggeredWithRatio:(CGFloat)ratio;
-(void)pullToRefreshDidStartLoading;
-(void)pullToRefreshDidStoppedLoading;



@end;
@interface UIScrollView (CCPullToRefresh)

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler refreshView:(CCRefreshView *)pullToRefreshView;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) CCRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end



