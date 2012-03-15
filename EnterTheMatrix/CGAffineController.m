//
//  CGAffineController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "CGAffineController.h"
#import "TransformTable.h"

@interface CGAffineController ()

@end

@implementation CGAffineController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Test:
	/*UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	square.backgroundColor = [UIColor purpleColor];
	square.layer.borderColor = [[UIColor blackColor] CGColor];
	square.layer.borderWidth = 2;
	[self.view addSubview:square];
	NSLog(@"O Frame =  %@", NSStringFromCGRect(square.frame));
	NSLog(@"O Bounds = %@", NSStringFromCGRect(square.bounds));
	NSLog(@"O Center = %@\n", NSStringFromCGPoint(square.center));
	CATransform3D t = CATransform3DMakeTranslation(60, 140, 0);
	square.layer.transform = t;
	NSLog(@"T Frame =  %@", NSStringFromCGRect(square.frame));
	NSLog(@"T Bounds = %@", NSStringFromCGRect(square.bounds));
	NSLog(@"T Center = %@\n", NSStringFromCGPoint(square.center));
	t = CATransform3DScale(t, 0.5, 0.5, 0.5);
	square.layer.transform = t;
	NSLog(@"S Frame =  %@", NSStringFromCGRect(square.frame));
	NSLog(@"S Bounds = %@", NSStringFromCGRect(square.bounds));
	NSLog(@"S Center = %@\n", NSStringFromCGPoint(square.center));
	t = CATransform3DRotate(t, radians(60), 0, 0, 1);
	square.layer.transform = t;
	NSLog(@"R Frame =  %@", NSStringFromCGRect(square.frame));
	NSLog(@"R Bounds = %@", NSStringFromCGRect(square.bounds));
	NSLog(@"R Center = %@\n", NSStringFromCGPoint(square.center));*/
}

@end
