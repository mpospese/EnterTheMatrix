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
#define FOLD_SHADOW_OPACITY 0.25

@interface FoldViewController()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *centerBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *skewSegment;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (readonly) CGFloat skew;

@property (assign, nonatomic, getter = isFolded) BOOL folded;
@property (assign, nonatomic, getter = isFolding) BOOL folding;
@property (assign, nonatomic) CGFloat pinchStartGap;
@property (assign, nonatomic) CGFloat lastProgress;
@property (assign, nonatomic) CGFloat durationMultiplier;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) CALayer *perspectiveLayer;
@property (strong, nonatomic) CALayer *topSleeve;
@property (strong, nonatomic) CALayer *bottomSleeve;
@property (strong, nonatomic) CAGradientLayer *upperFoldShadow;
@property (strong, nonatomic) CAGradientLayer *lowerFoldShadow;
@property (strong, nonatomic) CALayer *firstJointLayer;
@property (strong, nonatomic) CALayer *secondJointLayer;
@property (assign, nonatomic) CGPoint animationCenter;
@property (readonly, nonatomic) SkewMode skewMode;
@property (readonly, nonatomic) BOOL isInverse;

@property (strong, nonatomic) UIImage *slideUpperImage;
@property (strong, nonatomic) UIImage *foldUpperImage;
@property (strong, nonatomic) UIImage *foldLowerImage;
@property (strong, nonatomic) UIImage *slideLowerImage;

@end

@implementation FoldViewController

@synthesize folded;
@synthesize folding;
@synthesize pinchStartGap;
@synthesize lastProgress;

@synthesize animationView = _animationView;
@synthesize perspectiveLayer = _perspectiveLayer;
@synthesize topSleeve = _topSleeve;
@synthesize bottomSleeve = _bottomSleeve;
@synthesize upperFoldShadow = _upperFoldShadow;
@synthesize lowerFoldShadow = _lowerFoldShadow;
@synthesize firstJointLayer = _firstJointLayer;
@synthesize secondJointLayer = _secondJointLayer;
@synthesize animationCenter = _animationCenter;

@synthesize contentView;
@synthesize topBar;
@synthesize centerBar;
@synthesize bottomBar;
@synthesize skewSegment;
@synthesize controlFrame;
@synthesize durationMultiplier = _durationMultiplier;

- (void)doInit
{
	_durationMultiplier = 1;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
		[self doInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
		[self doInit];
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
	[self setDropShadow:self.contentView];
	[[self.contentView layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.contentView bounds]] CGPath]];
	
	// Add our tap gesture recognizer
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.contentView addGestureRecognizer:tapGesture];
	
	// Add our pinch gesture recognizer
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
    
    // render some images
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIImage *entire = [MPAnimation renderImageFromView:self.contentView withInsets:insets];
    
    CGFloat yOffset = 0;
	self.slideUpperImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.topBar.bounds.size.height + insets.top)];
    yOffset += self.slideUpperImage.size.height;
    self.foldUpperImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.centerBar.bounds.size.height/2)];
    yOffset += self.foldUpperImage.size.height;
    self.foldLowerImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.centerBar.bounds.size.height/2)];
    yOffset += self.foldLowerImage.size.height;
	self.slideLowerImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.bottomBar.bounds.size.height + insets.bottom)];
}

- (void)viewDidUnload
{
	[self setContentView:nil];
	[self setTopBar:nil];
	[self setCenterBar:nil];
	[self setBottomBar:nil];
	[self setSkewSegment:nil];
	[self setControlFrame:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// needed to keep view auto-sizing behavior from behaving badly with the optional side transform on contentView
	UIView *superview = [self.contentView superview];
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(superview.bounds)), roundf(CGRectGetMidY(superview.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 500, 380);	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	UIView *superview = [self.contentView superview];
	// needed to keep view auto-sizing behavior from behaving badly with the optional side transform on contentView
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(superview.bounds)), roundf(CGRectGetMidY(superview.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 500, 380);
}

#pragma mark - Properties

- (SkewMode)skewMode
{
	return (SkewMode)[self.skewSegment selectedSegmentIndex];
}

- (CGFloat)skew
{
	switch ([self skewMode])
	{
		case SkewModeInverse:
			return 1 / ((FOLD_HEIGHT / 2) *  4.666666667);
			
		case SkewModeNone:
		case SkewModeSide:
			return 0;
			
		case SkewModeLow:
			return -1 / ((FOLD_HEIGHT / 2) *  12);
			
		case SkewModeNormal:
			return -1 / ((FOLD_HEIGHT / 2) *  4.666666667);
			
		case SkewModeHigh:
			return -1 / ((FOLD_HEIGHT / 2) *  1.5);
	}
}

- (BOOL)isInverse
{
	return [self skewMode] == SkewModeInverse;
}
			
#pragma mark - methods

- (void)setDropShadow:(UIView *)view
{
	[self setDropShadowForLayer:[view layer]];
}

- (void)setDropShadowForLayer:(CALayer *)layer
{
	layer.shadowOpacity = 0.5;
	layer.shadowOffset = CGSizeMake(0, 3);
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

- (IBAction)skewValueChanged:(UISegmentedControl *)sender {
	BOOL wasSideView = !CATransform3DIsIdentity(self.contentView.layer.transform);
	BOOL isSideView = self.skewMode == SkewModeSide;
	
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	CATransform3D contentTransform = CATransform3DIdentity;
	
	if (isSideView)
	{
		// Special transform so that we can view the fold from the side
		perspectiveTransform.m34 = -0.0010;
		perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 30, -35, 0);
		perspectiveTransform = CATransform3DRotate(perspectiveTransform, radians(60), .75, 1, -0.5);
		contentTransform = perspectiveTransform;
	}
	else
		perspectiveTransform.m34 = [self skew];		
	
	if (isSideView != wasSideView)
	{
		// animate the change in view point
		CGFloat duration = DEFAULT_DURATION * [self durationMultiplier];
		[UIView animateWithDuration:duration animations:^{
			self.contentView.layer.transform = contentTransform;
		}];
	}
	else
		self.contentView.layer.transform = contentTransform;
	
	[[self perspectiveLayer] setSublayerTransform:perspectiveTransform];	
}

- (IBAction)durationValueChanged:(UISegmentedControl *)sender {
	switch ([sender selectedSegmentIndex]) {
		case 0:
			[self setDurationMultiplier:1];
			break;
			
		case 1:
			[self setDurationMultiplier:2];
			break;
			
		case 2:
			[self setDurationMultiplier:5];
			break;
			
		case 3:
			[self setDurationMultiplier:10];
			break;
			
		default:
			break;
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
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	[self setFolding:YES];
	[self buildLayers];
	[self doFold:[self isFolded]? 1 : 0];

	[CATransaction commit];
}

- (void)doFold:(CGFloat)difference
{
	CGFloat progress = fabsf(difference) / FOLD_HEIGHT;
	if ([self isFolded])
		progress = 1 - progress;
	
	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;
	
	if (progress == [self lastProgress])
		return;
	[self setLastProgress:progress];
	
	double angle = radians(90 * progress);
	double cosine = cos(angle);
	double foldHeight = cosine * FOLD_HEIGHT;
	//CGFloat scale = [[UIScreen mainScreen] scale];

	// to prevent flickering on non-retina devices (due to 1 point white border at edge of top and bottom panels),
	// keep height in pixels (not points) an integer, and back out correct angle from there
	/*foldHeight = round(foldHeight * scale) / scale;
	angle = acos(foldHeight / FOLD_HEIGHT);
	if (((int)(foldHeight * scale)) % 2 == 1)
	{
		// If height is an odd-# of pixels, shift position down half a pixel to keep top and bottom sleeves on pixel boundaries
		[self.animationView setCenter:CGPointMake(self.animationCenter.x, self.animationCenter.y + (0.5/scale))];
	}
	else 
	{
		[self.animationView setCenter:[self animationCenter]];
	}*/

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	self.firstJointLayer.transform = CATransform3DMakeRotation(-1*angle, 1, 0, 0);
	self.secondJointLayer.transform = CATransform3DMakeRotation(2*angle, 1, 0, 0);
	self.topSleeve.transform = CATransform3DMakeRotation(1*angle, 1, 0, 0);
	self.bottomSleeve.transform = CATransform3DMakeRotation(-1*angle, 1, 0, 0);
	
	self.upperFoldShadow.opacity = FOLD_SHADOW_OPACITY * (1- cosine);
	self.lowerFoldShadow.opacity = FOLD_SHADOW_OPACITY * (1 - cosine);
	
	self.perspectiveLayer.bounds = (CGRect){CGPointZero, CGSizeMake(self.perspectiveLayer.bounds.size.width, foldHeight)};

	[CATransaction commit];
}

- (void)endFold
{	
	BOOL finish = NO;
	if ([self isFolded])
	{
		finish = 1 - cosf(radians(90 * [self lastProgress])) <= 0.5;
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
	
	// remove the animation view and restore the center bar
	[self.animationView removeFromSuperview];
	self.animationView = nil;
	self.perspectiveLayer = nil;
	self.topSleeve = nil;
	self.bottomSleeve = nil;
	self.upperFoldShadow = nil;
	self.lowerFoldShadow = nil;
	self.firstJointLayer = nil;
	self.secondJointLayer = nil;
	
	if ([self isFolded])
	{
		self.topBar.transform = CGAffineTransformMakeTranslation(0, FOLD_HEIGHT/2);
		self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -FOLD_HEIGHT/2);
		[self.centerBar setHidden:YES];
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, FOLD_HEIGHT / 2, self.contentView.bounds.size.width, self.contentView.bounds.size.height - FOLD_HEIGHT)].CGPath;
	}
	else 
	{
		self.topBar.transform = CGAffineTransformIdentity;
		self.bottomBar.transform = CGAffineTransformIdentity;
		[self.centerBar setHidden:NO];
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds].CGPath;
	}
	[self.contentView setHidden:NO];	
}

- (void)animateFold:(BOOL)finish
{
	[self setFolding:YES];
	
	// Figure out how many frames we want
	CGFloat duration = DEFAULT_DURATION * [self durationMultiplier];
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
		
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		[self postFold:finish];
	}];
	
	[self.animationView setCenter:[self animationCenter]];

	BOOL vertical = YES;
	BOOL forwards = finish != [self isFolded];
	NSString *rotationKey = vertical? @"transform.rotation.x" : @"transform.rotation.y";
	double factor = (vertical? 1 : - 1) * M_PI / 180;
	CGFloat fromProgress = [self lastProgress];
	if (finish == [self isFolded])
		fromProgress = 1 - fromProgress;

	// fold the first (top) joint away from us
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:-90*factor*fromProgress] : [NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.firstJointLayer addAnimation:animation forKey:nil];
	
	// fold the second joint back towards us at twice the angle (since it's connected to the first fold we're folding away)
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:180*factor*fromProgress] : [NSNumber numberWithDouble:180*factor*(1-fromProgress)]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:180*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.secondJointLayer addAnimation:animation forKey:nil];
	
	// fold the bottom sleeve (3rd joint) away from us, so that net result is it lays flat from user's perspective
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:-90*factor*fromProgress] : [NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.bottomSleeve addAnimation:animation forKey:nil];
	
	// fold top sleeve towards us, so that net result is it lays flat from user's perspective
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:90*factor*fromProgress] : [NSNumber numberWithDouble:90*factor*(1-fromProgress)]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:90*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.topSleeve addAnimation:animation forKey:nil];

	// Build an array of keyframes for perspectiveLayer.bounds.size.height
	NSMutableArray* arrayHeight = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayShadow = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat cosine;
	CGFloat cosHeight;
	CGFloat cosShadow;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = fromProgress + (((1 - fromProgress) * frame) / frameCount);
		//progress = (((float)frame) / frameCount);
		cosine = forwards? cos(radians(90 * progress)) : sin(radians(90 * progress));
		if ((forwards && frame == frameCount) || (!forwards && frame == 0 && fromProgress == 0))
			cosine = 0;
		cosHeight = ((cosine)* FOLD_HEIGHT); // range from 2*height to 0 along a cosine curve
		[arrayHeight addObject:[NSNumber numberWithFloat:cosHeight]];
		
		cosShadow = FOLD_SHADOW_OPACITY * (1 - cosine);
		[arrayShadow addObject:[NSNumber numberWithFloat:cosShadow]];
	}
	
	// resize height of the 2 folding panels along a cosine curve.  This is necessary to maintain the 2nd joint in the center
	// Since there's no built-in sine timing curve, we'll use CAKeyframeAnimation to achieve it
	CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:vertical? @"bounds.size.height" : @"bounds.size.width"];
	[keyAnimation setValues:[NSArray arrayWithArray:arrayHeight]];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.perspectiveLayer addAnimation:keyAnimation forKey:nil];
	
	// Dim the 2 folding panels as they fold away from us
	keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	[keyAnimation setValues:arrayShadow];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.upperFoldShadow addAnimation:keyAnimation forKey:nil];
	
	keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	[keyAnimation setValues:arrayShadow];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.lowerFoldShadow addAnimation:keyAnimation forKey:nil];
					
	// commit the transaction
	[CATransaction commit];
}

- (void)buildLayers
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	BOOL vertical = YES;
	
	CGRect bounds = self.centerBar.bounds;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the folding panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets foldInsets = vertical? UIEdgeInsetsMake(0, 10, 0, 10) : UIEdgeInsetsMake(10, 0, 10, 0);
	// insets on top/bottom are only needed if we're transforming the entire view (in which case these edges need
	// anti-aliasing as well)
	
	CGRect upperRect = bounds;
	if (vertical)
		upperRect.size.height = bounds.size.height / 2;
	else
		upperRect.size.width = bounds.size.width / 2;
	CGRect lowerRect = upperRect;
	if (vertical)
		lowerRect.origin.y += upperRect.size.height;
	else
		lowerRect.origin.x += upperRect.size.width;
		
	[self.centerBar setHidden:NO];
	
	UIView *actingSource = self.contentView;
	UIView *containerView = [actingSource superview];
	[actingSource setHidden:YES];
	
	CATransform3D transform = self.contentView.layer.transform;
	CALayer *upperFold;
	CALayer *lowerFold;
	
	CGFloat width = vertical? bounds.size.width : bounds.size.height;
	CGFloat height = vertical? bounds.size.height/2 : bounds.size.width/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	CGFloat lowerHeight = (height * 2) - upperHeight;

	// view to hold all our sublayers
	self.contentView.layer.transform = CATransform3DIdentity; // need to temporarily remove transform before calling convertRect
	CGRect mainRect = [containerView convertRect:self.centerBar.frame fromView:actingSource];
	self.contentView.layer.transform = transform; // put the transform back
	self.animationView = [[UIView alloc] initWithFrame:mainRect];
	self.animationView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:self.animationView];
	[self setAnimationCenter:[self.animationView center]];
	
	// layer that covers the 2 folding panels in the middle
	self.perspectiveLayer = [CALayer layer];
	self.perspectiveLayer.frame = CGRectMake(0, 0, vertical? width : height * 2, vertical? height * 2 : width);
	[self.animationView.layer addSublayer:self.perspectiveLayer];
	
	// layer that encapsulates the join between the top sleeve (remains flat) and upper folding panel
	self.firstJointLayer = [CATransformLayer layer];
	self.firstJointLayer.frame = self.animationView.bounds;
	[self.perspectiveLayer addSublayer:self.firstJointLayer];
	
	// This remains flat, and is the upper half of the destination view when moving forwards
	// It slides down to meet the bottom sleeve in the center
	self.topSleeve = [CALayer layer];
	self.topSleeve.frame = (CGRect){CGPointZero, self.slideUpperImage.size};
	self.topSleeve.anchorPoint = CGPointMake(vertical? 0.5 : 1, vertical? 1 : 0.5);
	self.topSleeve.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width/2);
	[self.topSleeve setContents:(id)[self.slideUpperImage CGImage]];
	[self.firstJointLayer addSublayer:self.topSleeve];
	
	// This piece folds away from user along top edge, and is the upper half of the source view when moving forwards
	upperFold = [CALayer layer];
	upperFold.frame = (CGRect){CGPointZero, self.foldUpperImage.size};
	upperFold.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	upperFold.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	upperFold.contents = (id)[self.foldUpperImage CGImage];
	[self.firstJointLayer addSublayer:upperFold];
	
	// layer that encapsultates the join between the upper and lower folding panels (the V in the fold)
	self.secondJointLayer = [CATransformLayer layer];
	self.secondJointLayer.frame = self.animationView.bounds;
	self.secondJointLayer.frame = CGRectMake(0, 0, vertical? width : height * 2, vertical? height*2 : width);
	self.secondJointLayer.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	self.secondJointLayer.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width / 2);
	[self.firstJointLayer addSublayer:self.secondJointLayer];
	
	// This piece folds away from user along bottom edge, and is the lower half of the source view when moving forwards
	lowerFold = [CALayer layer];
	lowerFold.frame = (CGRect){CGPointZero, self.foldLowerImage.size};
	lowerFold.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	lowerFold.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	lowerFold.contents = (id)[self.foldLowerImage CGImage];
	[self.secondJointLayer addSublayer:lowerFold];
	
	// This remains flat, and is the lower half of the destination view when moving forwards
	// It slides up to meet the top sleeve in the center
	self.bottomSleeve = [CALayer layer];
	self.bottomSleeve.frame = (CGRect){CGPointZero, self.slideLowerImage.size};
	self.bottomSleeve.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	self.bottomSleeve.position = CGPointMake(vertical? width/2 : lowerHeight, vertical? lowerHeight : width / 2);
	[self.bottomSleeve setContents:(id)[self.slideLowerImage CGImage]];
	[self.secondJointLayer addSublayer:self.bottomSleeve];
	
	self.firstJointLayer.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	self.firstJointLayer.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	
	// Shadow layers to add shadowing to the 2 folding panels
	self.upperFoldShadow = [CAGradientLayer layer];
	[upperFold addSublayer:self.upperFoldShadow];
	self.upperFoldShadow.frame = CGRectInset(upperFold.bounds, foldInsets.left, foldInsets.top);
	//self.upperFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
	self.upperFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];	
	self.upperFoldShadow.startPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	self.upperFoldShadow.endPoint = CGPointMake(vertical? 0.5 : 1, vertical? 1 : 0.5);
	self.upperFoldShadow.opacity = 0;
	
	self.lowerFoldShadow = [CAGradientLayer layer];
	[lowerFold addSublayer:self.lowerFoldShadow];
	self.lowerFoldShadow.frame = CGRectInset(lowerFold.bounds, foldInsets.left, foldInsets.top);
	//self.lowerFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
	self.lowerFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor, nil];	
	self.lowerFoldShadow.startPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	self.lowerFoldShadow.endPoint = CGPointMake(vertical? 0.5 : 1, vertical? 1 : 0.5);
	self.lowerFoldShadow.opacity = 0;
		
	//[self setDropShadowForLayer:self.topSleeve];
	//[self setDropShadowForLayer:upperFold];
	//[self setDropShadowForLayer:lowerFold];
	//[self setDropShadowForLayer:self.bottomSleeve];
	
	// reduce shadow on topSleeve slightly so it won't shade the upperFold panel so much
	/*CGRect topBounds = CGRectMake(topInsets.left, topInsets.top, self.topSleeve.bounds.size.width - topInsets.left - topInsets.right, self.topSleeve.bounds.size.height - topInsets.top - topInsets.bottom - 3); // make it shorter by 3
	[self.topSleeve setShadowPath:[[UIBezierPath bezierPathWithRect:topBounds] CGPath]];
	
	CGRect upperFoldBounds = CGRectInset([upperFold bounds], foldInsets.left, foldInsets.top);
	upperFoldBounds.size.height -= 1;
	[upperFold setShadowPath:[[UIBezierPath bezierPathWithRect:upperFoldBounds] CGPath]];	
	
	CGRect lowerFoldBounds = CGRectInset([lowerFold bounds], foldInsets.left, foldInsets.top);
	lowerFoldBounds.size.height -= 1;
	[lowerFold setShadowPath:[[UIBezierPath bezierPathWithRect:lowerFoldBounds] CGPath]];
	
	CGRect bottomBounds = CGRectMake(bottomInsets.left, bottomInsets.top, self.bottomSleeve.bounds.size.width - bottomInsets.left - bottomInsets.right, self.bottomSleeve.bounds.size.height - bottomInsets.top - bottomInsets.bottom);
	[self.bottomSleeve setShadowPath:[[UIBezierPath bezierPathWithRect:bottomBounds] CGPath]];*/
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	transform.m34 = [self skew];
	self.perspectiveLayer.sublayerTransform = transform;
	
	[CATransaction commit];
}

@end
