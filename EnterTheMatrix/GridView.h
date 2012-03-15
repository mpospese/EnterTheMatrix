//
//  GridView.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransform.h"

@interface GridView : UIView

@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) NSUInteger translateHorz;
@property (assign, nonatomic) NSUInteger translateVert;
@property (assign, nonatomic) CGFloat scaleHorz;
@property (assign, nonatomic) CGFloat scaleVert;
@property (assign, nonatomic) CGFloat rotateHorz;
@property (assign, nonatomic) CGFloat rotateVert;

- (void)reset;

@end
