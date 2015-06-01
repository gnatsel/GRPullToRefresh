//
//  UIScrollView+CCInfiniteScrolling.h
//  OPIColorChat
//
//  Created by Olivier Lestang [DAN-PARIS] on 14/01/2015.
//  Copyright (c) 2015 TBWA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRefreshView.h"
@interface UIScrollView (CCInfiniteScrolling)
- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler  refreshView:(CCRefreshView *)infiniteScrollingView;
- (void)triggerInfiniteScrolling;

@property (nonatomic, strong, readonly) CCRefreshView *infiniteScrollingView;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;
@end
