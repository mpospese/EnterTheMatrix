//
//  BasicAnimationViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "BasicAnimationViewController.h"
#include <QuartzCore/QuartzCore.h>

#define MINOR_AXIS 100

@interface BasicAnimationViewController ()

@end

@implementation BasicAnimationViewController

@synthesize modeSegment;
@synthesize speedSwitch;
@synthesize translateSwitch;
@synthesize scaleSwitch;
@synthesize rotateSwitch;
@synthesize bar;
@synthesize translateLabel;
@synthesize scaleLabel;
@synthesize rotateLabel;
@synthesize controlFrame;
@synthesize orientation;

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

	orientation = OrientationBottom;
	[self addDropShadowToView:self.bar];
	[[self.bar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.bar bounds]] CGPath]];	
	
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	[self setBar:nil];
	[self setSpeedSwitch:nil];
	[self setModeSegment:nil];
	[self setTranslateSwitch:nil];
	[self setScaleSwitch:nil];
	[self setRotateSwitch:nil];
	[self setTranslateLabel:nil];
	[self setScaleLabel:nil];
	[self setRotateLabel:nil];
    [self setControlFrame:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)isFast
{
	return [[self speedSwitch] isOn];
}

- (BOOL)useTranslate
{
	return [[self translateSwitch] isOn];
}

- (BOOL)useScale
{
	return [[self scaleSwitch] isOn];
}

- (BOOL)useRotate
{
	return [[self rotateSwitch] isOn];
}

- (AnimationMode)animation
{
	return (AnimationMode)[[self modeSegment] selectedSegmentIndex];
}

- (IBAction)goPressed:(id)sender {
	
	CGRect newFrame;
	UIViewAutoresizing newResizing;
	OrientationMode newOrientation;
	CGSize viewSize = self.view.bounds.size;
	
	switch ([self orientation]) {
		case OrientationLeft:
			// rotating from left to top
			newFrame = CGRectMake(0, 0, viewSize.width, MINOR_AXIS);
			newOrientation = OrientationTop;
			newResizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
			break;
			
		case OrientationTop:
			// rotating from top to right
			newFrame = CGRectMake(viewSize.width - MINOR_AXIS, 0, MINOR_AXIS, viewSize.height);
			newOrientation = OrientationRight;
			newResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
			break;
			
		case OrientationRight:
			// rotating from right to bottom
			newFrame = CGRectMake(0, viewSize.height - MINOR_AXIS, viewSize.width, MINOR_AXIS);
			newOrientation = OrientationBottom;
			newResizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
			break;
			
		case OrientationBottom:
			// rotating from bottom to left
			newFrame = CGRectMake(0, 0, MINOR_AXIS, viewSize.height);
			newOrientation = OrientationLeft;
			newResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
			break;
	}
	
	[UIView animateWithDuration:([self isFast]? 0.5 : 2.5) 
						  delay:0 
						options:UIViewAnimationCurveEaseInOut 
					 animations:^{
		switch ([self animation]) {
			case AnimationFrame:
				self.bar.frame = newFrame;
			{
				// Because shadowPath is not an animatable property,
				// we have to create our own animation for it, but this is
				// pretty straight-forward
				CGPathRef oldPath = CGPathRetain([[self.bar layer] shadowPath]);
				[[self.bar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.bar bounds]] CGPath]];
				
				CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
				[pathAnimation setFromValue:(__bridge id)oldPath];
				[pathAnimation setToValue:(id)[[self.bar layer] shadowPath]];
				[pathAnimation setDuration:[self isFast]? 0.5 : 2.5];
				[pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
				[pathAnimation setRemovedOnCompletion:YES];
				
				[[self.bar layer] addAnimation:pathAnimation forKey:@"shadowPath"];
				CGPathRelease(oldPath);
			}
				break;
				
			case AnimationTransform:
			{
				CGAffineTransform t = CGAffineTransformIdentity;
				CGSize barSize = self.bar.bounds.size;
				
				switch ([self orientation]) {
					case OrientationLeft:
						// rotating from left to top
						if ([self useTranslate])
							t = CGAffineTransformTranslate(t, (viewSize.width - MINOR_AXIS)/2, -(barSize.height - MINOR_AXIS)/2);
						if ([self useRotate])
							t = CGAffineTransformRotate(t, radians(-90));
						if ([self useScale])
							t = CGAffineTransformScale(t, 1, viewSize.width / barSize.height);
						break;
						
					case OrientationTop:
						// rotating from top to right
						if ([self useTranslate])
							t = CGAffineTransformTranslate(t, (barSize.width - MINOR_AXIS)/2, (viewSize.height - MINOR_AXIS)/2);
						if ([self useRotate])
							t = CGAffineTransformRotate(t, radians(-90));
						if ([self useScale])
							t = CGAffineTransformScale(t, viewSize.height / barSize.width, 1);
						break;
						
					case OrientationRight:
						// rotating from right to bottom
						if ([self useTranslate])
							t = CGAffineTransformTranslate(t, -(viewSize.width - MINOR_AXIS)/2, (barSize.height - MINOR_AXIS)/2);
						if ([self useRotate])
							t = CGAffineTransformRotate(t, radians(-90));
						if ([self useScale])
							t = CGAffineTransformScale(t, 1, viewSize.width / barSize.height);
						break;
						
					case OrientationBottom:
						// rotating from bottom to left
						if ([self useTranslate])
							t = CGAffineTransformTranslate(t, -(barSize.width - MINOR_AXIS)/2, -(viewSize.height - MINOR_AXIS)/2);
						if ([self useRotate])
							t = CGAffineTransformRotate(t, radians(-90));
						if ([self useScale])
							t = CGAffineTransformScale(t, viewSize.height / barSize.width, 1);
						break;
				}
				
				self.bar.transform = t;
			}
				break;
		}
					 } completion:^(BOOL finished) {
						 
						 [UIView animateWithDuration:([self animation] == AnimationTransform && (![self useTranslate] || ![self useRotate] || ![self useScale]))? 0.5 : 0
										  animations:^{
											  self.bar.transform = CGAffineTransformIdentity;
											  self.bar.frame = newFrame;
											  [[self.bar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.bar bounds]] CGPath]];	
										  } completion:^(BOOL finished) {
											  self.orientation = newOrientation;
											  self.bar.autoresizingMask = newResizing;
										  }];
					 }
	 ];
}

- (IBAction)animationChanged:(id)sender {
	// enable/disable controls
	BOOL isTransform = [self animation] == AnimationTransform;

	translateSwitch.enabled = isTransform;
	scaleSwitch.enabled = isTransform;
	rotateSwitch.enabled = isTransform;

	translateLabel.textColor = isTransform? [UIColor darkTextColor] : [UIColor lightGrayColor];
	scaleLabel.textColor = isTransform? [UIColor darkTextColor] : [UIColor lightGrayColor];
	rotateLabel.textColor = isTransform? [UIColor darkTextColor] : [UIColor lightGrayColor];
}
@end
