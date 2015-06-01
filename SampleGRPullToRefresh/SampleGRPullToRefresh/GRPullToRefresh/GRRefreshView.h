//
//  GRPullToRefreshView.h
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 06/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(int, GRPullToRefreshState) {
    GRPullToRefreshStateStopped,
    GRPullToRefreshStateTriggered,
    GRPullToRefreshStateLoading
};
typedef NS_ENUM(int, GRInfiniteScrollingState) {
    GRInfiniteScrollingStateStopped,
    GRInfiniteScrollingStateTriggered,
    GRInfiniteScrollingStateLoading
};
typedef NS_ENUM(int, GRRefreshStyle) {
    GRRefreshStyleNone,
    GRRefreshStylePullToRefresh,
    GRRefreshStyleInfiniteScrolling
};
@class GRRefreshView;
@protocol GRRefreshViewDelegate <NSObject>
@optional
-(void)refreshViewDidEndRefreshing:(GRRefreshView *)refreshView;

@end
@interface GRRefreshView : UIView
@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat originalTopInset;
@property (nonatomic, assign) CGFloat originalBottomInset;
@property (nonatomic, weak) id<GRRefreshViewDelegate> delegate;

@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) GRPullToRefreshState pullToRefreshState;
@property (nonatomic, assign) GRInfiniteScrollingState infiniteScrollingState;
@property (nonatomic, assign) GRRefreshStyle refreshStyle;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) BOOL shouldEndAnimating;
@property (nonatomic, strong) NSDictionary *infoDictionary;

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);
@property (nonatomic, copy) void (^infiniteScrollingActionHandler)(void);


-(void)resetScrollViewContentInset;
-(void)pullToRefreshTriggeringWithRatio:(CGFloat)ratio;
-(void)infiniteScrollingTriggeringWithRatio:(CGFloat)ratio;
- (void)setScrollViewContentInsetForInfiniteScrolling;
-(void)startRefreshing;
-(void)endRefreshing;
@end
