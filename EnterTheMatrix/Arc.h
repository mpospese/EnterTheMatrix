//
//  Arc.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/11/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Arc : UIView

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat arcWidth;
@property (nonatomic, assign) CGFloat arcOpacity;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* highlightColor;
@property (nonatomic, readonly) CGFloat innerRadius;
@property (nonatomic, readonly) CGFloat midRadius;
@property (nonatomic, readonly) CGFloat outerRadius;
@property (nonatomic, readonly) CGPoint arCenter;

@end
