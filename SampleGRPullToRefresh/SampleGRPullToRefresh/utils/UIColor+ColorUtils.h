//
//  UIColor+ColorUtils.h
//  SampleGRPullToRefresh
//
//  Created by Olivier Lestang [DAN-PARIS] on 01/06/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorUtils)
+ (UIColor*)colorWithHex:(NSString*)hexValue;
+ (UIColor *)randomColor;
@end
