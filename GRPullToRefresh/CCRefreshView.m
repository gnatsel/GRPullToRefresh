//
//  CCPullToRefreshView.m
//  OPIColorChat
//
//  Created by Olivier Lestang [DAN-PARIS] on 06/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CCRefreshView.h"
#import "UIScrollView+CCPullToRefresh.h"
#import "UIScrollView+CCInfiniteScrolling.h"

@implementation CCRefreshView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil && [self.superview isKindOfClass:[UIScrollView class]]) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (self.isObserving) {
            if (self.refreshStyle == CCRefreshStylePullToRefresh && scrollView.showsPullToRefresh) {
                
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
            else if (self.refreshStyle == CCRefreshStyleInfiniteScrolling && scrollView.showsInfiniteScrolling) {
                
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
    else if(self.refreshStyle == CCRefreshStyleInfiniteScrolling && [keyPath isEqualToString:@"contentSize"]) {
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
    if(self.refreshStyle == CCRefreshStylePullToRefresh){
        self.pullToRefreshState = CCPullToRefreshStateStopped;
        if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
    }
    if(self.refreshStyle == CCRefreshStyleInfiniteScrolling){
        self.infiniteScrollingState = CCInfiniteScrollingStateStopped;
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
        case CCRefreshStyleNone:
        {
            break;
        }
        case CCRefreshStylePullToRefresh:
        {
            [self scrollViewDidScrollForPullToRefresh:contentOffset];
            break;
        }
        case CCRefreshStyleInfiniteScrolling:
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
    if(self.pullToRefreshState != CCPullToRefreshStateLoading) {
        
        if(self.pullToRefreshState == CCPullToRefreshStateTriggered && ratio == 1){
            self.pullToRefreshState = CCPullToRefreshStateLoading;
            [self pullToRefreshTriggeringWithRatio:ratio];
            
        }
        else if(ratio < 1 && self.scrollView.isDragging && self.pullToRefreshState != CCPullToRefreshStateLoading){
            self.pullToRefreshState = CCPullToRefreshStateTriggered;
            [self pullToRefreshTriggeringWithRatio:ratio];
            
            
        }
        else if(!self.scrollView.isDragging && self.pullToRefreshState != CCPullToRefreshStateStopped){
            [self pullToRefreshTriggeringWithRatio:0];
            
        }
    } else {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
}

- (void)setPullToRefreshState:(CCPullToRefreshState)newState {
    
    if(_pullToRefreshState == newState)
        return;
    CCPullToRefreshState previousState = _pullToRefreshState;
    _pullToRefreshState = newState;
    
    
    switch (newState) {
        case CCPullToRefreshStateStopped:{
            [self resetScrollViewContentInset];
            break;
        }
            
            
        case CCPullToRefreshStateTriggered:{
            break;
        }
            
        case CCPullToRefreshStateLoading:
            [self startRefreshing];
            [self setScrollViewContentInsetForLoading];
            if(previousState == CCPullToRefreshStateTriggered && _pullToRefreshActionHandler)
                _pullToRefreshActionHandler();
            break;
        default:
            break;
    }
}
- (void)scrollViewDidScrollForInfiniteScrolling:(CGPoint)contentOffset{
    if(self.infiniteScrollingState != CCPullToRefreshStateLoading) {
        CGFloat ratio = 0;
        if(self.scrollView.contentOffset.y >= 0){
            ratio = (self.scrollView.contentOffset.y +self.scrollView.frame.size.height-self.scrollView.contentSize.height)/(2*self.frame.size.height);
            ratio = ratio < 0 ? 0 : ratio;
            ratio = ratio > 1 ? 1 : ratio;
        }
        
        if(self.infiniteScrollingState == CCInfiniteScrollingStateTriggered && ratio == 1)
            self.infiniteScrollingState = CCInfiniteScrollingStateLoading;
        else if(ratio < 1 && self.scrollView.isDragging && self.infiniteScrollingState == CCInfiniteScrollingStateStopped)
            self.infiniteScrollingState = CCInfiniteScrollingStateTriggered;
        else if(!self.scrollView.isDragging && self.infiniteScrollingState != CCInfiniteScrollingStateStopped)
            self.infiniteScrollingState = CCInfiniteScrollingStateStopped;
    }
}

-(void)logViews:(UIView *)view defaultPadding:(NSString *)defaultPadding padding:(NSString *)padding{
    if([view isKindOfClass:[UIScrollView class]]){
        UIScrollView *sv = (UIScrollView *)view;
        NSLog(@"%@%@ %@ ;contentInset: %@;contentSize: %@",defaultPadding,padding,sv, NSStringFromUIEdgeInsets(sv.contentInset), NSStringFromCGSize(sv.contentSize));
    }
    else NSLog(@"%@%@ %@",defaultPadding,padding,view);
    for(UIView *subview in view.subviews){
        [self logViews:subview defaultPadding:[defaultPadding stringByAppendingString:padding] padding:padding];
    }
}
- (void)setInfiniteScrollingState:(CCInfiniteScrollingState)newState {
    
    if(_infiniteScrollingState == newState)
        return;
    
    CCInfiniteScrollingState previousState = _infiniteScrollingState;
    _infiniteScrollingState = newState;
    switch (newState) {
        case CCInfiniteScrollingStateStopped:{
            break;
        }
            
            
        case CCInfiniteScrollingStateTriggered:{
            break;
        }
            
        case CCInfiniteScrollingStateLoading:
            [self startRefreshing];
            if(previousState == CCInfiniteScrollingStateTriggered && _infiniteScrollingActionHandler)
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
