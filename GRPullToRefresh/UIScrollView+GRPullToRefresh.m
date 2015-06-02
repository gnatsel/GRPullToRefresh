//
//  UIScrollView+GRPullToRefresh.m
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 05/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <objc/runtime.h>
#import "UIScrollView+GRPullToRefresh.h"

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (GRPullToRefresh)
- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler refreshView:(GRRefreshView *)pullToRefreshView{
    if(!self.pullToRefreshView) {
        pullToRefreshView.scrollView = self;
        
        pullToRefreshView.frame = CGRectMake((CGRectGetWidth(self.frame)-CGRectGetWidth(pullToRefreshView.frame))/2,
                                             -CGRectGetHeight(pullToRefreshView.frame),
                                             CGRectGetWidth(pullToRefreshView.frame),
                                             CGRectGetHeight(pullToRefreshView.frame));
        pullToRefreshView.originalFrame = pullToRefreshView.frame;
        [self addSubview:pullToRefreshView];
        
        pullToRefreshView.originalTopInset = self.contentInset.top;
        pullToRefreshView.refreshStyle = GRRefreshStylePullToRefresh;
        self.pullToRefreshView = pullToRefreshView;
        self.pullToRefreshView.pullToRefreshActionHandler = actionHandler;

        self.showsPullToRefresh = YES;
    }
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.pullToRefreshState = GRPullToRefreshStateTriggered;
    self.pullToRefreshView.pullToRefreshState = GRPullToRefreshStateLoading;

}

- (void)setPullToRefreshView:(GRRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (GRRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
        if (self.pullToRefreshView.isObserving) {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];

            [self.pullToRefreshView resetScrollViewContentInset];
            self.pullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.pullToRefreshView.isObserving) {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

            self.pullToRefreshView.isObserving = YES;
        }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}
@end
