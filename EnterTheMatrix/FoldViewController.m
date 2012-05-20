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
#define DEFAULT_DURATION 0.3
#define DEFAULT_SKEW	-(1. / 280)

@interface FoldViewController ()

@property (assign, nonatomic, getter = isFolded) BOOL folded;
@property (assign, nonatomic, getter = isFolding) BOOL folding;
@property (assign, nonatomic) CGFloat pinchStartGap;
@property (assign, nonatomic) CGFloat lastProgress;

@end

@implementation FoldViewController

@synthesize folded;
@synthesize folding;
@synthesize pinchStartGap;
@synthesize lastProgress;
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
	
	// Set drop shadows and shadow paths on views
	self.controlFrame.layer.cornerRadius = 5;
	[self setDropShadow:self.controlFrame];
	[[self.controlFrame layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[self.controlFrame bounds] cornerRadius:5] CGPath]];	
	[self setDropShadow:self.topBar];
	[self setDropShadow:self.centerBar];
	[self setDropShadow:self.bottomBar];
	[[self.topBar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.topBar bounds]] CGPath]];	
	[[self.centerBar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.centerBar bounds]] CGPath]];	
	[[self.bottomBar layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.bottomBar bounds]] CGPath]];	
	
	// Add our tap gesture recognizer
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.contentView addGestureRecognizer:tapGesture];
	
	// Add our pinch gesture recognizer
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
	
	// We want to split the center bar in 2 and create 2 images from it- these will be our folding halves
	
	// Calculate the 2 rects
	CGRect barRect = self.centerBar.bounds;
	CGRect topRect = barRect;
	topRect.size.height = barRect.size.height / 2;
	CGRect bottomRect = topRect;
	bottomRect.origin.y = topRect.size.height;
	
	// paint the images from the view
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
	UIImage *topImage = [MPAnimation renderImageForAntialiasing:[MPAnimation renderImageFromView:self.centerBar withRect:topRect] withInsets:insets];
	UIImage *bottomImage = [MPAnimation renderImageForAntialiasing:[MPAnimation renderImageFromView:self.centerBar withRect:bottomRect] withInsets:insets];
	
	// account for 1-pixel clear margin we introduced for anti-aliasing
	topRect = CGRectInset(topRect, -insets.left, -insets.top);
	bottomRect = CGRectInset(bottomRect, -insets.left, -insets.top);

	// create UIImageView's to hold the images
	[self setFoldTop: [[UIImageView alloc] initWithImage:topImage]];
	self.foldTop.frame = topRect;
	self.foldTop.layer.anchorPoint = CGPointMake(0.5, 0); // anchor at top
	[self setFoldBottom:[[UIImageView alloc] initWithImage:bottomImage]];
	self.foldBottom.frame = bottomRect;
	self.foldBottom.layer.anchorPoint = CGPointMake(0.5, 1); // anchor at bottom
	[self setDropShadow:self.foldTop];
	[self setDropShadow:self.foldBottom];
	[[self.foldTop layer] setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.foldTop bounds], insets.left, insets.top)] CGPath]];	
	[[self.foldBottom layer] setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.foldBottom bounds], insets.left, insets.top)] CGPath]];
}

- (void)viewDidUnload
{
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
			return degrees(atan(4.666666667));
			
		case SkewModeNone:
			return 90;
			
		case SkewModeOut:
			return 90 + degrees(atan(1/4.666666667));
	}
}

#pragma mark - methods

- (void)setDropShadow:(UIView *)view
{
	view.layer.shadowOpacity = 0.5;
	view.layer.shadowOffset = CGSizeMake(0, 1);
}

#pragma mark - Gesture handlers

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
	[self setLastProgress:0];
	[self startFold];
	[self animateFold:YES];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = [gestureRecognizer state];
	
	CGFloat currentGap = [self pinchStartGap];
	if (state != UIGestureRecognizerStateEnded && gestureRecognizer.numberOfTouches == 2)
	{
		CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:self.view];
		CGPoint p2 = [gestureRecognizer locationOfTouch:1 inView:self.view];
		currentGap = fabsf(p1.y - p2.y);
    }
	
    if (state == UIGestureRecognizerStateBegan)
    {		
		[self setPinchStartGap:currentGap];
		[self startFold];
    }
	
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
		[self endFold];
    }
	else if (state == UIGestureRecognizerStateChanged && gestureRecognizer.numberOfTouches == 2)
	{
		if ([self isFolded])
		{
			// pinching out, want + diff
			if (currentGap < [self pinchStartGap])
				currentGap = [self pinchStartGap]; // min
			
			if (currentGap > [self pinchStartGap] + FOLD_HEIGHT)
				currentGap = [self pinchStartGap] + FOLD_HEIGHT; // max
		}
		else 
		{
			// pinching in, want - diff
			if (currentGap < [self pinchStartGap] - FOLD_HEIGHT)
				currentGap = [self pinchStartGap] - FOLD_HEIGHT; // min
			
			if (currentGap > [self pinchStartGap])
				currentGap = [self pinchStartGap]; // max
		}
		
		[self doFold:currentGap - [self pinchStartGap]];
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return ![self isFolding];
}

#pragma mark - Animations

- (void)startFold
{
	[self setFolding:YES];
	// replace the center bar with the 2 image halves
	CGRect barRect =  self.centerBar.frame;//[self.contentView convertRect:self.centerBar.frame fromView:self.centerBar];
	CGRect topRect = barRect;
	topRect.size.height = barRect.size.height / 2;
	CGRect bottomRect = topRect;
	bottomRect.origin.y += topRect.size.height;
	
	// account for 1-pixel clear margin we introduced for anti-aliasing
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
	topRect = CGRectInset(topRect, -insets.left, -insets.top);
	bottomRect = CGRectInset(bottomRect, -insets.left, -insets.top);

	self.foldTop.frame = topRect;
	self.foldBottom.frame = bottomRect;

	[self.contentView insertSubview:foldTop aboveSubview:self.centerBar];
	[self.contentView insertSubview:foldBottom aboveSubview:self.foldTop];

	[self.centerBar setHidden:YES];
}

- (void)doFold:(CGFloat)difference
{
	CGFloat progress = fabsf(difference) / FOLD_HEIGHT;
	if (progress == [self lastProgress])
		return;
	[self setLastProgress:progress];
	
	CATransform3D tUpperFold;
	CATransform3D tLowerFold;
	
	CGFloat verticalOffset = [self calculateFold:progress upperFold:&tUpperFold lowerFold:&tLowerFold];
	
	self.topBar.layer.transform = CATransform3DMakeTranslation(0, verticalOffset, 0);
	self.bottomBar.layer.transform = CATransform3DMakeTranslation(0, -verticalOffset, 0);
	self.foldTop.layer.transform = tUpperFold;
	self.foldBottom.layer.transform = tLowerFold;
}

- (CGFloat)calculateFold:(CGFloat)progress upperFold:(CATransform3D*)upperFoldTransform lowerFold:(CATransform3D*)lowerFoldTransform{
	if ([self isFolded])
		progress = 1 - progress;
	
	// We need to move the folding flaps towards the center based on the cosine of the angle of our fold
	// Basically what this does is keep the bottom of the top fold (and top of the bottom fold) anchored to the midpoint.
	CGFloat cosine = cosf(radians(90 * progress));
	CGFloat verticalOffset = (FOLD_HEIGHT / 2) * (1- cosine); // how much to offset each panel by
	
	// fold the top and bottom halves of the center panel away from us
	CATransform3D tTop = CATransform3DIdentity;
	tTop.m34 = [self skew] * progress;
	tTop = CATransform3DTranslate(tTop, 0, verticalOffset, 0); // shift panel towards center
	tTop = CATransform3DRotate(tTop, radians([self skewAngle] * progress), -1, 0, 0); // rotate away from viewer
	*upperFoldTransform = tTop;
	
	CATransform3D tBottom = CATransform3DIdentity;
	tBottom.m34 = [self skew] * progress;
	tBottom = CATransform3DTranslate(tBottom, 0, -verticalOffset, 0); // shift panel towards center
	tBottom = CATransform3DRotate(tBottom, radians(-[self skewAngle] * progress), -1, 0, 0); // rotate away from viewer
	self.foldBottom.layer.transform = tBottom;
	*lowerFoldTransform = tBottom;
	
	return verticalOffset;
}

- (void)endFold
{	
	BOOL finish = NO;
	if ([self isFolded])
	{
		finish = 1 - cosf(radians(90 * (1-[self lastProgress]))) <= 0.5;		
	}
	else
	{
		finish = 1 - cosf(radians(90 * [self lastProgress])) >= 0.5;
	}
	
	if ([self lastProgress] > 0 && [self lastProgress] < 1)
		[self animateFold:finish];
	else
		[self postFold:finish];
}

// Post fold cleanup (for animation completion block)
- (void)postFold:(BOOL)finish
{
	[self setFolding:NO];
	
	// final animation completed
	if (finish)
		[self setFolded:![self isFolded]];
	
	// remove the 2 image halves and restore the center bar
	[foldTop removeFromSuperview];
	[foldBottom removeFromSuperview];
	
	if (![self isFolded])
	{
		self.topBar.transform = CGAffineTransformIdentity;
		self.bottomBar.transform = CGAffineTransformIdentity;
		[self.centerBar setHidden:NO];
	}
}

- (void)animateFold:(BOOL)finish
{
	[self setFolding:YES];
	
	// Figure out how many frames we want
	CGFloat duration = DEFAULT_DURATION;
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Build an array of keyframes (each a single transform)
	NSMutableArray* arrayTop = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayUpperFold = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayLowerFold = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayBottom = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat toProgress = finish? 1 : 0;
	CGFloat progress;
	CGFloat verticalOffset;
	CATransform3D upperFold, lowerFold;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = [self lastProgress] + (((toProgress - [self lastProgress]) * frame) / frameCount);
		verticalOffset = [self calculateFold:progress upperFold:&upperFold lowerFold:&lowerFold];
		[arrayTop addObject:[NSNumber numberWithFloat:verticalOffset]];
		[arrayUpperFold addObject:[NSValue valueWithCATransform3D:upperFold]];
		[arrayLowerFold addObject:[NSValue valueWithCATransform3D:lowerFold]];
		[arrayBottom addObject:[NSNumber numberWithFloat:-verticalOffset]];
	}
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		[self postFold:finish];
	}];
	
	// Create the 4 animations
	CAKeyframeAnimation *animationTop = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"]; 
	[animationTop setValues:[NSArray arrayWithArray:arrayTop]]; 		
	[animationTop setRemovedOnCompletion:YES];
	
	CAKeyframeAnimation *animationUpperFold = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	[animationUpperFold setValues:[NSArray arrayWithArray:arrayUpperFold]]; 		
	[animationUpperFold setRemovedOnCompletion:YES];
	
	CAKeyframeAnimation *animationLowerFold = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	[animationLowerFold setValues:[NSArray arrayWithArray:arrayLowerFold]]; 		
	[animationLowerFold setRemovedOnCompletion:YES];
	
	CAKeyframeAnimation *animationBottom = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"]; 
	[animationBottom setValues:[NSArray arrayWithArray:arrayBottom]]; 		
	[animationBottom setRemovedOnCompletion:YES];
	
	// add the animations
	[self.topBar.layer addAnimation:animationTop forKey:@"transformTop"];
	[self.foldTop.layer addAnimation:animationUpperFold forKey:@"transformUpperFold"];
	[self.foldBottom.layer addAnimation:animationLowerFold forKey:@"transformLowerFold"];
	[self.bottomBar.layer addAnimation:animationBottom forKey:@"transformBottom"];
	
	// set final states
	[self.topBar.layer setTransform:CATransform3DMakeTranslation(0, [[[animationTop values] lastObject] floatValue], 0)];
	[self.foldTop.layer setTransform:[[[animationUpperFold values] lastObject] CATransform3DValue]];
	[self.foldBottom.layer setTransform:[[[animationLowerFold values] lastObject] CATransform3DValue]];
	[self.bottomBar.layer setTransform:CATransform3DMakeTranslation(0, [[[animationBottom values] lastObject] floatValue], 0)];
	
	// commit the transaction
	[CATransaction commit];
}


@end
