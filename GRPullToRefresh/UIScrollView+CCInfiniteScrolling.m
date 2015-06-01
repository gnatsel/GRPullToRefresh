//
//  UIScrollView+CCInfiniteScrolling.m
//  OPIColorChat
//
//  Created by Olivier Lestang [DAN-PARIS] on 14/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//

#import "UIScrollView+CCInfiniteScrolling.h"
#import <objc/runtime.h>

static char UIScrollViewInfiniteScrollingView;
@implementation UIScrollView (CCInfiniteScrolling)


@dynamic infiniteScrollingView;

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler refreshView:(CCRefreshView *)infiniteScrollingView{
    
    if(!self.infiniteScrollingView) {
        infiniteScrollingView.frame = CGRectMake((self.bounds.size.width - infiniteScrollingView.frame.size.width) /2, self.frame.size.height, infiniteScrollingView.frame.size.width, infiniteScrollingView.frame.size.height);
        infiniteScrollingView.infiniteScrollingActionHandler = actionHandler;
        infiniteScrollingView.scrollView = self;
        [self addSubview:infiniteScrollingView];
        
        infiniteScrollingView.originalBottomInset = self.contentInset.bottom;
        infiniteScrollingView.refreshStyle = CCRefreshStyleInfiniteScrolling;

        self.infiniteScrollingView = infiniteScrollingView;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)triggerInfiniteScrolling {
    self.infiniteScrollingView.infiniteScrollingState = CCInfiniteScrollingStateTriggered;
    self.infiniteScrollingView.infiniteScrollingState = CCInfiniteScrollingStateLoading;

}

- (void)setInfiniteScrollingView:(CCRefreshView *)infiniteScrollingView {
    [self willChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingView,
                             infiniteScrollingView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
}

- (CCRefreshView *)infiniteScrollingView {
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingView);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling {
    self.infiniteScrollingView.hidden = !showsInfiniteScrolling;
    
    if(!showsInfiniteScrolling) {
        if (self.infiniteScrollingView.isObserving) {
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentOffset"];
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentSize"];
            [self.infiniteScrollingView resetScrollViewContentInset];
            self.infiniteScrollingView.isObserving = NO;
        }
    }
    else {
        if (!self.infiniteScrollingView.isObserving) {

            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.infiniteScrollingView setScrollViewContentInsetForInfiniteScrolling];
            self.infiniteScrollingView.isObserving = YES;
            
            [self.infiniteScrollingView setNeedsLayout];
            self.infiniteScrollingView.frame = CGRectMake((self.bounds.size.width - self.infiniteScrollingView.frame.size.width) /2, self.contentSize.height, self.infiniteScrollingView.frame.size.width, self.infiniteScrollingView.frame.size.height);
        }
    }
}

- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingView.hidden;
}

@end
