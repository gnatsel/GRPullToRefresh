//
//  UIScrollView+GRInfiniteScrolling.h
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 14/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRRefreshView.h"
@interface UIScrollView (GRInfiniteScrolling)
- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler  refreshView:(GRRefreshView *)infiniteScrollingView;
- (void)triggerInfiniteScrolling;

@property (nonatomic, strong, readonly) GRRefreshView *infiniteScrollingView;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;
@end
