//
//  MPAnimation.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAnimation : NSObject

+ (UIImage*)renderImageFromView:(UIView *)view withRect:(CGRect)frame;
+ (UIImage *)renderImage:(UIImage *)image withMargin:(CGFloat)width color:(UIColor *)color;
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets;
@end
