//
//  CATransformController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "CATransformController.h"

@interface CATransformController ()

@end
 
@implementation CATransformController

#pragma mark - Property

- (BOOL)is3D
{
	return YES;
}

- (NSString *)imageName
{
	return @"matrix_01";
}

@end
