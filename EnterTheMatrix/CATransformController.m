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

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end
 
@implementation CATransformController
@synthesize backgroundView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.backgroundView setBackgroundColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"Blueprint"]] colorWithAlphaComponent:0.5]];
}

#pragma mark - Property

- (BOOL)is3D
{
	return YES;
}

- (NSString *)imageName
{
	return @"matrix_01";
}

- (void)viewDidUnload {
	[self setBackgroundView:nil];
	[super viewDidUnload];
}
@end
