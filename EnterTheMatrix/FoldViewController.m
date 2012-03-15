//
//  FoldViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "FoldViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MPAnimation.h"

#define FOLD_HEIGHT	120.
#define DEFAULT_SKEW	-(1. / 500.)
#define SKEW_ANGLE_OFFSET	7

@interface FoldViewController ()

@end

@implementation FoldViewController
@synthesize scrollView;
@synthesize contentView;
@synthesize topBar;
@synthesize centerBar;
@synthesize bottomBar;
@synthesize skewSegment;
@synthesize controlFrame;
@synthesize foldBottom;
@synthesize foldTop;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.controlFrame.layer.cornerRadius = 5;
	[self setDropShadow:self.controlFrame];
	[self setDropShadow:self.topBar];
	[self setDropShadow:self.centerBar];
	[self setDropShadow:self.bottomBar];
	
	// Add our pinch gesture recognizer
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.view addGestureRecognizer:pinchGesture];
	
	// We want to split the center bar in 2 and create 2 images from it- these will be our folding halves
	
	// Calculate the 2 rects
	CGRect barRect = self.centerBar.bounds;
	CGRect topRect = barRect;
	topRect.size.height = barRect.size.height / 2;
	CGRect bottomRect = topRect;
	bottomRect.origin.y = topRect.size.height;
	
	// paint the images from the view
	UIImage *topImage = [MPAnimation renderImageFromView:self.centerBar withRect:topRect];
	UIImage *bottomImage = [MPAnimation renderImageFromView:self.centerBar withRect:bottomRect];
	
	// create UIImageView's to hold the images
	[self setFoldTop: [[UIImageView alloc] initWithImage:topImage]];
	self.foldTop.frame = topRect;
	self.foldTop.layer.anchorPoint = CGPointMake(0.5, 0); // anchor at top
	[self setFoldBottom:[[UIImageView alloc] initWithImage:bottomImage]];
	self.foldBottom.frame = bottomRect;
	self.foldBottom.layer.anchorPoint = CGPointMake(0.5, 1); // anchor at bottom
	[self setDropShadow:self.foldTop];
	[self setDropShadow:self.foldBottom];
}

- (void)viewDidUnload
{
	[self setScrollView:nil];
	[self setContentView:nil];
	[self setTopBar:nil];
	[self setCenterBar:nil];
	[self setBottomBar:nil];
	[self setFoldTop:nil];
	[self setFoldBottom:nil];
    [self setSkewSegment:nil];
    [self setControlFrame:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Properties

- (CGFloat)skew
{
	switch ((SkewMode)[self.skewSegment selectedSegmentIndex])
	{
		case SkewModeIn:
			return DEFAULT_SKEW;
			
		case SkewModeNone:
			return 0;
			
		case SkewModeOut:
			return -DEFAULT_SKEW;
	}
}

- (CGFloat)skewAngle
{
	switch ((SkewMode)[self.skewSegment selectedSegmentIndex])
	{
		case SkewModeIn:
			return 90 - SKEW_ANGLE_OFFSET;
			
		case SkewModeNone:
			return 90;
			
		case SkewModeOut:
			return 90 + SKEW_ANGLE_OFFSET;
	}
}

#pragma mark - methods

- (void)setDropShadow:(UIView *)view
{
	view.layer.shadowOpacity = 0.5;
	view.layer.shadowOffset = CGSizeMake(0, 1);
}

#pragma mark - Gesture handlers

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = [gestureRecognizer state];
	
	CGFloat currentGap = pinchStartGap;
	if (state != UIGestureRecognizerStateEnded && gestureRecognizer.numberOfTouches == 2)
	{
		CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:self.view];
		CGPoint p2 = [gestureRecognizer locationOfTouch:1 inView:self.view];
		currentGap = fabsf(p1.y - p2.y);
    }
	
    if (state == UIGestureRecognizerStateBegan)
    {		
		pinchStartGap = currentGap;
		[self startFold];
    }
	
    if (state == UIGestureRecognizerStateEnded)
    {
		[self endFold];
    }
	else if (state == UIGestureRecognizerStateChanged && gestureRecognizer.numberOfTouches == 2)
	{
		if (folded)
		{
			// pinching out, want + diff
			if (currentGap < pinchStartGap)
				currentGap = pinchStartGap; // min
			
			if (currentGap > pinchStartGap + FOLD_HEIGHT)
				currentGap = pinchStartGap + FOLD_HEIGHT; // max
		}
		else 
		{
			// pinching in, want - diff
			if (currentGap < pinchStartGap - FOLD_HEIGHT)
				currentGap = pinchStartGap - FOLD_HEIGHT; // min
			
			if (currentGap > pinchStartGap)
				currentGap = pinchStartGap; // max
		}
		
		[self doFold:currentGap - pinchStartGap];
	}
}

#pragma mark - Animations

- (void)startFold
{
	// replace the center bar with the 2 image halves
	CGRect barRect =  self.centerBar.frame;//[self.contentView convertRect:self.centerBar.frame fromView:self.centerBar];
	CGRect topRect = barRect;
	topRect.size.height = barRect.size.height / 2;
	CGRect bottomRect = topRect;
	bottomRect.origin.y += topRect.size.height;
	
	self.foldTop.frame = topRect;
	self.foldBottom.frame = bottomRect;

	[self.contentView insertSubview:foldTop belowSubview:self.topBar];
	[self.contentView insertSubview:foldBottom belowSubview:self.bottomBar];

	[self.centerBar setHidden:YES];
}

- (void)doFold:(CGFloat)difference
{
	CGFloat progress = fabsf(difference) / FOLD_HEIGHT;
	if (progress == lastProgress)
		return;
	lastProgress = progress;
	if (folded)
		progress = 1-progress;
	
	//self.topBar.transform = CGAffineTransformMakeTranslation(0, -difference/2);
	//self.bottomBar.transform = CGAffineTransformMakeTranslation(0, difference/2);

	// We need to move the folding flaps towards the center based on the cosine of the angle of our fold
	// Basically what this does is keep the bottom of the top fold (and top of the bottom fold) anchored to the midpoint.
	CGFloat cosine = cosf(radians(90 * progress));
	CGFloat verticalOffset = (FOLD_HEIGHT / 2) * (1- cosine); // how much to offset each panel by
	
	// move the top and bottom panels towards the center
	self.topBar.transform = CGAffineTransformMakeTranslation(0, verticalOffset);
	self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -verticalOffset);
	
	// fold the top and bottom halves of the center panel away from us
	CATransform3D tTop = CATransform3DIdentity;
	tTop.m34 = [self skew] * progress;
	tTop = CATransform3DTranslate(tTop, 0, verticalOffset, 0); // shift panel towards center
	tTop = CATransform3DRotate(tTop, radians([self skewAngle] * progress), -1, 0, 0); // rotate away from viewer
	self.foldTop.layer.transform = tTop;
	
	CATransform3D tBottom = CATransform3DIdentity;
	tBottom.m34 = [self skew] * progress;
	tBottom = CATransform3DTranslate(tBottom, 0, -verticalOffset, 0); // shift panel towards center
	tBottom = CATransform3DRotate(tBottom, radians(-[self skewAngle] * progress), -1, 0, 0); // rotate away from viewer
	self.foldBottom.layer.transform = tBottom;
}

- (void)endFold
{	
	BOOL finish = NO;
	if (folded)
	{
		finish = 1 - cosf(radians(90 * (1-lastProgress))) <= 0.5;		
	}
	else
	{
		finish = 1 - cosf(radians(90 * lastProgress)) >= 0.5;
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		if (finish)
		{
			[self doFold:FOLD_HEIGHT];
		}
		else
		{
			[self doFold:0];
		}
	} completion:^(BOOL finished) {
		
		if (finish)
			folded = !folded;
		
		// remove the 2 image halves and restore the center bar
		[foldTop removeFromSuperview];
		[foldBottom removeFromSuperview];

		if (!folded)
		{
			self.topBar.transform = CGAffineTransformIdentity;
			self.bottomBar.transform = CGAffineTransformIdentity;
			[self.centerBar setHidden:NO];
		}
	}];
	
}


@end
