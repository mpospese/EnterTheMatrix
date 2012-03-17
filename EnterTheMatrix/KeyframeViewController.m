//
//  KeyframeViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "KeyframeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KeyframeViewController ()

@end

@implementation KeyframeViewController
@synthesize arc;
@synthesize bottomLabel;
@synthesize topLabel;
@synthesize speedSwitch;
@synthesize modeSegment;
@synthesize arcPositionSegment;
@synthesize controlFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addDropShadowToView:(UIView *)view
{
	view.layer.shadowOpacity = 0.5;
	view.layer.shadowOffset = CGSizeMake(0, 3);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.controlFrame.layer.cornerRadius = 5;
	[self addDropShadowToView:self.controlFrame];
	[[self.controlFrame layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[self.controlFrame bounds] cornerRadius:5] CGPath]];	
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.arc addGestureRecognizer:tap];
	
	self.topLabel.transform = CGAffineTransformMakeRotation(radians(90));
	self.bottomLabel.transform = CGAffineTransformMakeRotation(radians(-90));
	self.arc.layer.transform = [self transformView:self.arc forAngle:-90 aboutRotationPoint:self.arc.arCenter];
	arcPosition = ArcPositionDown;
}

- (void)viewDidUnload
{
	[self setArc:nil];
	[self setSpeedSwitch:nil];
	[self setModeSegment:nil];
	[self setBottomLabel:nil];
	[self setTopLabel:nil];
	[self setArcPositionSegment:nil];
	[self setControlFrame:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Calculations

- (CATransform3D)transformView:(UIView *)view forAngle:(CGFloat)anAngle aboutRotationPoint:(CGPoint)rotationPoint
{
	// get original (untransformed) center of this view
	CGPoint center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, rotationPoint.x-center.x, rotationPoint.y-center.y, 0.0);
    transform = CATransform3DRotate(transform, radians(anAngle), 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, center.x-rotationPoint.x, center.y-rotationPoint.y, 0.0);
    return transform;
}

#pragma mark - Animation

- (CGFloat)positionToAngle:(ArcPosition)position
{
	switch (position) {
		case ArcPositionDown:
			return -90;
		
		case ArcPositionMid:
			return 0;
			
		case ArcPositionUp:
			return 90;
	}
}

- (void)animateToPosition:(ArcPosition)position
{
	if (arcPosition == position)
		return;
	
	CGFloat fromAngle = [self positionToAngle:arcPosition];
	CGFloat toAngle = [self positionToAngle:position];
	CGPoint rotationPoint = [self.arc arCenter];
	
	if (self.modeSegment.selectedSegmentIndex == AnimationModeBasic)
	{
		// Basic animation - just set the transform to the desired value
		[UIView animateWithDuration:([self.speedSwitch isOn]? 0.5 : 2.5) 
							  delay:0 options:UIViewAnimationCurveEaseInOut 
						 animations:^{
			
							 self.arc.layer.transform = [self transformView:self.arc forAngle:toAngle aboutRotationPoint:rotationPoint];
							 
						 } 
						 completion:nil
		 ];
	}
	else
	{
		// Keyframe animation
		
		// Figure out how many frames we want
		CGFloat duration = [self.speedSwitch isOn]? 0.5 : 2.5;
		NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
		
		// Build an array of keyframes (each a single transform)
		NSMutableArray* array = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat step = ((CGFloat)(toAngle - fromAngle))/((CGFloat)frameCount);
		BOOL isClockWise = toAngle > fromAngle;
		for (CGFloat degree = fromAngle; isClockWise? degree <= toAngle : degree >= toAngle; degree += step)
		{
			[array addObject:[NSValue valueWithCATransform3D:[self transformView:self.arc forAngle:degree aboutRotationPoint:rotationPoint]]];
		}
		
		// Create the animation
		// (we're animating transform property)
		CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
		// set our keyframe values
		[animation setValues:[NSArray arrayWithArray:array]]; 		
		[animation setDuration:duration];
		[animation setTimingFunction:
		 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
		[animation setRemovedOnCompletion:YES];
		
		// add the animation
		[self.arc.layer addAnimation:animation forKey:@"transform"];
		// set final state
		NSValue* toValue = [animation.values lastObject];
		[self.arc.layer setTransform:[toValue CATransform3DValue]];
	}

	arcPosition = position;
}

#pragma mark - Gesture handlers

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
	ArcPosition newPosition;
	switch (arcPosition)
	{
		case ArcPositionDown:
			newPosition = ArcPositionMid;
			movingUp = YES;
			break;
			
		case ArcPositionMid:
			newPosition = movingUp? ArcPositionUp : ArcPositionDown;
			break;
			
		case ArcPositionUp:
			newPosition = ArcPositionMid;
			movingUp = NO;
	}
	
	[self animateToPosition:newPosition];
	[self.arcPositionSegment setSelectedSegmentIndex:newPosition];
}

- (IBAction)arcPositionValueChanged:(id)sender {
	UISegmentedControl *segment = sender;
	ArcPosition newPosition = [segment selectedSegmentIndex];

	if (newPosition == ArcPositionMid && newPosition != arcPosition)
		movingUp = arcPosition == ArcPositionDown;
	
	[self animateToPosition:newPosition];
}

@end
