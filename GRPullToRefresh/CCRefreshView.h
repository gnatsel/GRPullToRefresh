//
//  CCPullToRefreshView.h
//  OPIColorChat
//
//  Created by Olivier Lestang [DAN-PARIS] on 06/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(int, CCPullToRefreshState) {
    CCPullToRefreshStateStopped,
    CCPullToRefreshStateTriggered,
    CCPullToRefreshStateLoading
};
typedef NS_ENUM(int, CCInfiniteScrollingState) {
    CCInfiniteScrollingStateStopped,
    CCInfiniteScrollingStateTriggered,
    CCInfiniteScrollingStateLoading
};
typedef NS_ENUM(int, CCRefreshStyle) {
    CCRefreshStyleNone,
    CCRefreshStylePullToRefresh,
    CCRefreshStyleInfiniteScrolling
};
@class CCRefreshView;
@protocol CCRefreshViewDelegate <NSObject>
@optional
-(void)refreshViewDidEndRefreshing:(CCRefreshView *)refreshView;

@end
@interface CCRefreshView : UIView
@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat originalTopInset;
@property (nonatomic, assign) CGFloat originalBottomInset;
@property (nonatomic, weak) id<CCRefreshViewDelegate> delegate;

@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) CCPullToRefreshState pullToRefreshState;
@property (nonatomic, assign) CCInfiniteScrollingState infiniteScrollingState;
@property (nonatomic, assign) CCRefreshStyle refreshStyle;
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
