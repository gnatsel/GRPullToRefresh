//
//  GRPullToRefreshView.m
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 06/01/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GRRefreshView.h"
#import "UIScrollView+GRPullToRefresh.h"
#import "UIScrollView+GRInfiniteScrolling.h"

@implementation GRRefreshView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil && [self.superview isKindOfClass:[UIScrollView class]]) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (self.isObserving) {
            if (self.refreshStyle == GRRefreshStylePullToRefresh && scrollView.showsPullToRefresh) {
                
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
            else if (self.refreshStyle == GRRefreshStyleInfiniteScrolling && scrollView.showsInfiniteScrolling) {
                
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
    else if([keyPath isEqualToString:@"contentInset"]){
        self.originalTopInset = [[change valueForKey:NSKeyValueChangeNewKey] UIEdgeInsetsValue].top;
        self.originalBottomInset = [[change valueForKey:NSKeyValueChangeNewKey] UIEdgeInsetsValue].bottom;

    }
    else if(self.refreshStyle == GRRefreshStyleInfiniteScrolling && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        self.frame = CGRectMake(self.frame.origin.x, self.scrollView.contentSize.height, self.bounds.size.width, self.frame.size.height);
    }
}
- (void)startRefreshing{
    if(fabs(self.scrollView.contentOffset.y) < FLT_EPSILON) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    
}

- (void)endRefreshing{
    if(self.refreshStyle == GRRefreshStylePullToRefresh){
        self.pullToRefreshState = GRPullToRefreshStateStopped;
        if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
    }
    if(self.refreshStyle == GRRefreshStyleInfiniteScrolling){
        self.infiniteScrollingState = GRInfiniteScrollingStateStopped;
    }
    [self performSelector:@selector(didEndRefreshing) withObject:nil afterDelay:0.3];
}

-(void)didEndRefreshing{
    if([self.delegate respondsToSelector:@selector(refreshViewDidEndRefreshing:)]){
        
        [self.delegate refreshViewDidEndRefreshing:self];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    switch(self.refreshStyle){
        case GRRefreshStyleNone:
        {
            break;
        }
        case GRRefreshStylePullToRefresh:
        {
            [self scrollViewDidScrollForPullToRefresh:contentOffset];
            break;
        }
        case GRRefreshStyleInfiniteScrolling:
        {
            [self scrollViewDidScrollForInfiniteScrolling:contentOffset];
            break;
        }
        default: break;
    }
}
- (void)scrollViewDidScrollForPullToRefresh:(CGPoint)contentOffset {
    CGFloat ratio = -(self.originalTopInset +self.scrollView.contentOffset.y + CGRectGetHeight(self.frame)/2)/ CGRectGetHeight(self.frame);
    ratio = ratio < 0 ? 0 : ratio;
    ratio = ratio > 1 ? 1 : ratio;
    if(self.pullToRefreshState != GRPullToRefreshStateLoading) {
        
        if(self.pullToRefreshState == GRPullToRefreshStateTriggered && ratio == 1){
            self.pullToRefreshState = GRPullToRefreshStateLoading;
            [self pullToRefreshTriggeringWithRatio:ratio];
            
        }
        else if(ratio < 1 && self.scrollView.isDragging && self.pullToRefreshState != GRPullToRefreshStateLoading){
            self.pullToRefreshState = GRPullToRefreshStateTriggered;
            [self pullToRefreshTriggeringWithRatio:ratio];
            
            
        }
        else if(!self.scrollView.isDragging && self.pullToRefreshState != GRPullToRefreshStateStopped){
            [self pullToRefreshTriggeringWithRatio:0];
            
        }
    } else {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
}

- (void)setPullToRefreshState:(GRPullToRefreshState)newState {
    
    if(_pullToRefreshState == newState)
        return;
    GRPullToRefreshState previousState = _pullToRefreshState;
    _pullToRefreshState = newState;
    
    
    switch (newState) {
        case GRPullToRefreshStateStopped:{
            [self resetScrollViewContentInset];
            break;
        }
            
            
        case GRPullToRefreshStateTriggered:{
            break;
        }
            
        case GRPullToRefreshStateLoading:
            [self startRefreshing];
            [self setScrollViewContentInsetForLoading];
            if(previousState == GRPullToRefreshStateTriggered && _pullToRefreshActionHandler)
                _pullToRefreshActionHandler();
            break;
        default:
            break;
    }
}
- (void)scrollViewDidScrollForInfiniteScrolling:(CGPoint)contentOffset{
    if(self.infiniteScrollingState != GRPullToRefreshStateLoading) {
        CGFloat ratio = 0;
        if(self.scrollView.contentOffset.y >= 0){
            ratio = (self.scrollView.contentOffset.y +self.scrollView.frame.size.height-self.scrollView.contentSize.height)/(2*self.frame.size.height);
            ratio = ratio < 0 ? 0 : ratio;
            ratio = ratio > 1 ? 1 : ratio;
        }
        
        if(self.infiniteScrollingState == GRInfiniteScrollingStateTriggered && ratio == 1)
            self.infiniteScrollingState = GRInfiniteScrollingStateLoading;
        else if(ratio < 1 && self.scrollView.isDragging && self.infiniteScrollingState == GRInfiniteScrollingStateStopped)
            self.infiniteScrollingState = GRInfiniteScrollingStateTriggered;
        else if(!self.scrollView.isDragging && self.infiniteScrollingState != GRInfiniteScrollingStateStopped)
            self.infiniteScrollingState = GRInfiniteScrollingStateStopped;
    }
}

- (void)setInfiniteScrollingState:(GRInfiniteScrollingState)newState {
    
    if(_infiniteScrollingState == newState)
        return;
    
    GRInfiniteScrollingState previousState = _infiniteScrollingState;
    _infiniteScrollingState = newState;
    switch (newState) {
        case GRInfiniteScrollingStateStopped:{
            break;
        }
            
            
        case GRInfiniteScrollingStateTriggered:{
            break;
        }
            
        case GRInfiniteScrollingStateLoading:
            [self startRefreshing];
            if(previousState == GRInfiniteScrollingStateTriggered && _infiniteScrollingActionHandler)
                _infiniteScrollingActionHandler();
            break;
        default:
            break;
    }

}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + self.frame.size.height;
    [self setScrollViewContentInset:currentInsets];
}
-(void)pullToRefreshTriggeringWithRatio:(CGFloat)ratio{
}
-(void)infiniteScrollingTriggeringWithRatio:(CGFloat)ratio{
    
}
@end
