//
//  FlipViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "FlipViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MPAnimation.h"

#define IMAGE_COUNT 4
#define DEFAULT_DURATION 0.3
#define DEFAULT_SKEW	-(1. / 1000.)
#define ANGLE	90
#define MARGIN	72

#define SWIPE_UP_THRESHOLD -100.0f
#define SWIPE_DOWN_THRESHOLD 100.0f
#define SWIPE_LEFT_THRESHOLD -100.0f
#define SWIPE_RIGHT_THRESHOLD 100.0f

@interface FlipViewController ()

@property(assign, nonatomic) int currentImageIndex;
@property(assign, nonatomic) FlipDirection direction;
@property(assign, nonatomic) FlipOrientation orientation;
@property(assign, nonatomic, getter = isFlipFrontPage) BOOL flipFrontPage;
@property(assign, nonatomic, getter = isAnimating) BOOL animating;
@property(assign, nonatomic, getter = isPanning) BOOL panning;
@property(assign, nonatomic) CGPoint panStart;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) CALayer *layerFront;
@property (strong, nonatomic) CALayer *layerFacing;
@property (strong, nonatomic) CALayer *layerBack;
@property (strong, nonatomic) CALayer *layerReveal;
@property (strong, nonatomic) CAGradientLayer *layerFrontShadow;
@property (strong, nonatomic) CAGradientLayer *layerBackShadow;
@property (strong, nonatomic) CALayer *layerFacingShadow;
@property (strong, nonatomic) CALayer *layerRevealShadow;

@end

@implementation FlipViewController

@synthesize currentImageIndex;
@synthesize direction;
@synthesize orientation;
@synthesize flipFrontPage;
@synthesize animating;
@synthesize panning;
@synthesize panStart;
@synthesize animationView = _animationView;
@synthesize layerFront = _layerFront;
@synthesize layerFacing = _layerFacing;
@synthesize layerBack = _layerBack;
@synthesize layerReveal = _layerReveal;
@synthesize layerFrontShadow = _layerFrontShadow;
@synthesize layerBackShadow = _layerBackShadow;
@synthesize layerFacingShadow = _layerFacingShadow;
@synthesize layerRevealShadow = _layerRevealShadow;
@synthesize contentView;
@synthesize imageView;
@synthesize speedSwitch;
@synthesize skewSlider;
@synthesize skewLabel;
@synthesize controlFrame;

- (void)doInit
{
	direction = FlipDirectionForward;
	orientation = FlipOrientationVertical;
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

- (void)addDropShadowToView:(UIView *)view
{
	view.layer.shadowOpacity = 0.5;
	view.layer.shadowOffset = CGSizeMake(0, 3);
}

- (void)setShadowPathOnView:(UIView *)view
{
	[[view layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[view bounds] cornerRadius:5] CGPath]];	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.controlFrame.layer.cornerRadius = 5;
	[self addDropShadowToView:self.controlFrame];
	[self setShadowPathOnView:self.controlFrame];

	UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	left.direction = UISwipeGestureRecognizerDirectionLeft;
	left.delegate = self;
	[self.view addGestureRecognizer:left];
	
	UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	right.direction = UISwipeGestureRecognizerDirectionRight;
	right.delegate = self;
	[self.view addGestureRecognizer:right];
	
	UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	up.direction = UISwipeGestureRecognizerDirectionUp;
	up.delegate = self;
	[self.view addGestureRecognizer:up];
	
	UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	down.direction = UISwipeGestureRecognizerDirectionDown;
	down.delegate = self;
	[self.view addGestureRecognizer:down];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.contentView addGestureRecognizer:tap];
	
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	pan.delegate = self;
	[self.contentView addGestureRecognizer:pan];
	
	// drop-shadow for content view
	[self addDropShadowToView:self.contentView];
	[[self.contentView layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.contentView bounds]] CGPath]];	
}

- (void)viewDidUnload
{
	[self setContentView:nil];
	[self setImageView:nil];
	[self setSpeedSwitch:nil];
	[self setSkewSlider:nil];
	[self setSkewLabel:nil];
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
	return -[[self skewSlider] value];
}

#pragma mark - Gesture handlers

- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer
{
	if ([self isAnimating] || [self isPanning])
		return;
	
	UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gestureRecognizer;
	
	switch (swipeGesture.direction)
	{
		case UISwipeGestureRecognizerDirectionLeft:
			[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationHorizontal];
			break;
		
		case UISwipeGestureRecognizerDirectionUp:
			[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationVertical];
			break;
			
		case UISwipeGestureRecognizerDirectionRight:
			[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationHorizontal];
			break;
			
		case UISwipeGestureRecognizerDirectionDown:
			[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationVertical];
			break;
	}
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if ([self isAnimating] || [self isPanning])
		return;
	
	CGPoint tapPoint = [gestureRecognizer locationInView:self.contentView];
	if (tapPoint.x <= MARGIN)
		[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationHorizontal];
	else if (tapPoint.x >= self.contentView.bounds.size.width - MARGIN)
		[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationHorizontal];
	else if (tapPoint.y <= MARGIN)
		[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationVertical];
	else if (tapPoint.y >= self.contentView.bounds.size.height - MARGIN)
		[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationVertical];
}
	
- (CGFloat)progressFromPosition:(CGPoint)position
{
	// Determine where we are in our page turn animation
	// 0 - 1 means flipping the front-side of the page
	// 1 - 2 means flipping the back-side of the page
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);
	
	CGFloat difference = isVertical? position.y - panStart.y : position.x - panStart.x;
	CGFloat halfWidth = (isVertical? self.contentView.frame.size.height / 2 : self.contentView.frame.size.width / 2);
	CGFloat progress = difference / halfWidth * (isForward? - 1 : 1);
	if (progress < 0)
		progress = 0;
	if (progress > 2)
		progress = 2;
	return progress;
}

// switching between the 2 halves of the animation - between front and back sides of the page we're turning
- (void)switchToStage:(int)stageIndex
{
	// 0 = stage 1, 1 = stage 2
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	if (stageIndex == 0)
	{
		[self doFlip2:0];
		[self.animationView.layer insertSublayer:self.layerFacing above:self.layerReveal];
		[self.animationView.layer insertSublayer:self.layerFront below:self.layerFacing];
		[self.layerReveal addSublayer:self.layerRevealShadow];
		[self.layerBack removeFromSuperlayer];
		[self.layerFacingShadow removeFromSuperlayer];
	}
	else
	{
		[self doFlip1:1];
		[self.animationView.layer insertSublayer:self.layerReveal above:self.layerFacing];
		[self.animationView.layer insertSublayer:self.layerBack below:self.layerReveal];
		[self.layerFacing addSublayer:self.layerFacingShadow];
		[self.layerFront removeFromSuperlayer];
		[self.layerRevealShadow removeFromSuperlayer];
	}
	
	[CATransaction commit];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = [gestureRecognizer state];
	CGPoint currentPosition = [gestureRecognizer locationInView:self.contentView];
	
	if (state == UIGestureRecognizerStateBegan)
	{
		if ([self isAnimating])
			return;
		
		// See if touch started near one of the edges, in which case we'll pan a page turn
		if (currentPosition.x <= MARGIN)
			[self startFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationHorizontal];
		else if (currentPosition.x >= self.contentView.bounds.size.width - MARGIN)
			[self startFlipWithDirection:FlipDirectionForward orientation:FlipOrientationHorizontal];
		else if (currentPosition.y <= MARGIN)
			[self startFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationVertical];
		else if (currentPosition.y >= self.contentView.bounds.size.height - MARGIN)
			[self startFlipWithDirection:FlipDirectionForward orientation:FlipOrientationVertical];
		else
		{
			// Do nothing for now, but it might become a swipe later
			return;
		}
		
		[self setAnimating:YES];
		[self setPanning:YES];
		panStart = currentPosition;
	}
	
	if ([self isPanning] && state == UIGestureRecognizerStateChanged)
	{
		CGFloat progress = [self progressFromPosition:currentPosition];
		BOOL wasFlipFrontPage = [self isFlipFrontPage];
		[self setFlipFrontPage:progress < 1];
		if (wasFlipFrontPage != [self isFlipFrontPage])
		{
			// switching between the 2 halves of the animation - between front and back sides of the page we're turning
			[self switchToStage:[self isFlipFrontPage]? 0 : 1];
		}
		if ([self isFlipFrontPage])
			[self doFlip1:progress];
		else
			[self doFlip2:progress - 1];
	}
	
	if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
		
		if ([self isPanning])
        {
			// If moving slowly, let page fall either forward or back depending on where we were
			BOOL shouldFallBack = [self isFlipFrontPage];
			
			// But, if user was swiping in an appropriate direction, go ahead and honor that
			if (orientation == FlipOrientationHorizontal)
			{
				if (vel.x < SWIPE_LEFT_THRESHOLD)
				{
					// Detected a swipe to the left
					shouldFallBack = direction != FlipDirectionForward;
				}
				else if (vel.x > SWIPE_RIGHT_THRESHOLD)
				{
					// Detected a swipe to the right
					shouldFallBack = direction == FlipDirectionForward;
				}				
			}
			else
			{
				if (vel.y < SWIPE_UP_THRESHOLD)
				{
					// Detected a swipe up
					shouldFallBack = direction != FlipDirectionForward;
				}
				else if (vel.y > SWIPE_DOWN_THRESHOLD)
				{
					// Detected a swipe down
					shouldFallBack = direction == FlipDirectionForward;
				}
			}
			
			// finishAnimation
			if (shouldFallBack != [self isFlipFrontPage])
			{
				// 2-stage animation (we're swiping either forward or back)
				CGFloat progress = [self progressFromPosition:currentPosition];
				if (([self isFlipFrontPage] && progress > 1) || (![self isFlipFrontPage] && progress < 1))
					progress = 1;
				if (progress > 1)
					progress -= 1;
				[self animateFlip1:shouldFallBack fromProgress:progress];
			}
			else
			{
				// 1-stage animation
				CGFloat fromProgress = [self progressFromPosition:currentPosition];
				if (!shouldFallBack)
					fromProgress -= 1;
				[self animateFlip2:shouldFallBack fromProgress:fromProgress];
			}
        }
		else if (![self isAnimating])
		{
			// we weren't panning (because touch didn't start near any margin) but test for swipe
			if (vel.x < SWIPE_LEFT_THRESHOLD)
			{
				// Detected a swipe to the left
				[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationHorizontal];
			}
			else if (vel.x > SWIPE_RIGHT_THRESHOLD)
			{
				// Detected a swipe to the right
				[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationHorizontal];
			}
			else if (vel.y < SWIPE_UP_THRESHOLD)
			{
				// TODO: Detected a swipe up
				[self performFlipWithDirection:FlipDirectionForward orientation:FlipOrientationVertical];
			}
			else if (vel.y > SWIPE_DOWN_THRESHOLD)
			{
				// TODO: Detected a swipe down
				[self performFlipWithDirection:FlipDirectionBackward orientation:FlipOrientationVertical];
			}
		}
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// don't recognize any further gestures if we're in the middle of animating a page-turn
	if ([self isAnimating])
		return NO;
	
	// don't recognize swipe on a slider!
	return ![touch.view isKindOfClass:[UISlider class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	// Allow simultanoues pan & swipe recognizers
	return YES;
}

#pragma mark - Animation

- (UIImage *)currentImage
{
	return [UIImage imageNamed:[NSString stringWithFormat:@"matrix_%02d", [self currentImageIndex] + 1]];
}

- (UIImage *)prevImage
{
	int prevIndex = ([self currentImageIndex] + (IMAGE_COUNT - 1)) % IMAGE_COUNT;
	return [UIImage imageNamed:[NSString stringWithFormat:@"matrix_%02d", prevIndex + 1]];
}

- (UIImage *)nextImage
{
	int nextIndex = ([self currentImageIndex] + 1) % IMAGE_COUNT;
	return [UIImage imageNamed:[NSString stringWithFormat:@"matrix_%02d", nextIndex + 1]];
}

- (void)performFlipWithDirection:(FlipDirection)aDirection orientation:(FlipOrientation)anOrientation
{
	[self setAnimating:YES];
	[self startFlipWithDirection:aDirection orientation:anOrientation];
	
	[self animateFlip1:NO fromProgress:0];
}

- (void)animateFlip1:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress
{
	// 2-stage animation
	CALayer *layer = shouldFallBack? self.layerBack : self.layerFront;
	CALayer *flippingShadow = shouldFallBack? self.layerBackShadow : self.layerFrontShadow;
	CALayer *coveredShadow = shouldFallBack? self.layerFacingShadow : self.layerRevealShadow;
	
	if (shouldFallBack)
		fromProgress = 1 - fromProgress;
	CGFloat toProgress = 1;

	// Figure out how many frames we want
	CGFloat duration = DEFAULT_DURATION * ([self.speedSwitch isOn]? 1 : 5) * (toProgress - fromProgress);
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		// 2nd half of animation, once 1st half completes
		[self setFlipFrontPage:shouldFallBack];
		[self switchToStage:shouldFallBack? 0 : 1];
		
		[self animateFlip2:shouldFallBack fromProgress:shouldFallBack? 1 : 0];
	}];
	
	// Create the animation
	BOOL forwards = [self direction] == FlipDirectionForward;
	BOOL vertical = [self orientation] == FlipOrientationVertical;
	BOOL inward = NO;
	NSString *rotationKey = vertical? @"transform.rotation.x" : @"transform.rotation.y";
	double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * (vertical? -1 : 1) * M_PI / 180;

	// Flip front page from flat up to vertical
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:[NSNumber numberWithDouble:90 * factor * fromProgress]];
	[animation setToValue:[NSNumber numberWithDouble:90*factor]];
	[layer addAnimation:animation forKey:nil];
	[layer setTransform:CATransform3DMakeRotation(90*factor, vertical? 1 : 0, vertical? 0 : 1, 0)];

	// Shadows
	
	// darken front page just slightly as we flip (just to give it a crease where it touches facing page)
	animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[animation setFromValue:[NSNumber numberWithDouble:0.1 * fromProgress]];
	[animation setToValue:[NSNumber numberWithDouble:0.1]];
	[flippingShadow addAnimation:animation forKey:nil];
	[flippingShadow setOpacity:0.1];
	
	if (!inward)
	{
		// lighten the page that is revealed by front page flipping up (along a cosine curve)
		// TODO: consider FROM value
		NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat progress;
		CGFloat cosOpacity;
		for (int frame = 0; frame <= frameCount; frame++)
		{
			progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
			//progress = (((float)frame) / frameCount);
			cosOpacity = cos(radians(90 * progress)) * (1./3);
			if (frame == frameCount)
				cosOpacity = 0;
			[arrayOpacity addObject:[NSNumber numberWithFloat:cosOpacity]];
		}
		
		CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
		[coveredShadow addAnimation:keyAnimation forKey:nil];
		[coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];
	}
	
	// shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
	NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat shadowProgress;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
		shadowProgress = progress * 8;
		if (shadowProgress > 1)
			shadowProgress = 1;
		
		[arrayOpacity addObject:[NSNumber numberWithFloat:0.5 * shadowProgress]];
	}
	
	CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
	[keyAnimation setCalculationMode:kCAAnimationLinear];
	[keyAnimation setValues:arrayOpacity];
	[layer addAnimation:keyAnimation forKey:nil];
	[layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];
	
	// Commit the transaction for 1st half
	[CATransaction commit];
}

- (void)animateFlip2:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress
{
	// 1-stage animation
	CALayer *layer = shouldFallBack? self.layerFront : self.layerBack;
	CALayer *flippingShadow = shouldFallBack? self.layerFrontShadow : self.layerBackShadow;
	CALayer *coveredShadow = shouldFallBack? self.layerRevealShadow : self.layerFacingShadow;
	
	// Figure out how many frames we want
	CGFloat duration = DEFAULT_DURATION * ([self.speedSwitch isOn]? 1 : 5);
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Build an array of keyframes (each a single transform)
	if (shouldFallBack)
		fromProgress = 1 - fromProgress;
	CGFloat toProgress = 1;
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		// once 2nd half completes
		[self endFlip:!shouldFallBack];
		
		// Clear flags
		[self setAnimating:NO];
		[self setPanning:NO];
	}];
	
	// Create the animation
	BOOL forwards = [self direction] == FlipDirectionForward;
	BOOL vertical = [self orientation] == FlipOrientationVertical;
	BOOL inward = NO;
	NSString *rotationKey = vertical? @"transform.rotation.x" : @"transform.rotation.y";
	double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * (vertical? -1 : 1) * M_PI / 180;
	
	// Flip back page from vertical down to flat
	CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation2 setFromValue:[NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
	[animation2 setToValue:[NSNumber numberWithDouble:0]];
	[animation2 setFillMode:kCAFillModeForwards];
	[animation2 setRemovedOnCompletion:NO];
	[layer addAnimation:animation2 forKey:nil];
	[layer setTransform:CATransform3DIdentity];
	
	// Shadows
	
	// Lighten back page just slightly as we flip (just to give it a crease where it touches reveal page)
	animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[animation2 setFromValue:[NSNumber numberWithDouble:0.1 * (1-fromProgress)]];
	[animation2 setToValue:[NSNumber numberWithDouble:0]];
	[animation2 setFillMode:kCAFillModeForwards];
	[animation2 setRemovedOnCompletion:NO];
	[flippingShadow addAnimation:animation2 forKey:nil];
	[flippingShadow setOpacity:0];
	
	if (!inward)
	{
		// Darken facing page as it gets covered by back page flipping down (along a sine curve)
		NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat progress;
		CGFloat sinOpacity;
		for (int frame = 0; frame <= frameCount; frame++)
		{
			progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
			sinOpacity = (sin(radians(90 * progress))* (1./3));
			if (frame == 0)
				sinOpacity = 0;
			[arrayOpacity addObject:[NSNumber numberWithFloat:sinOpacity]];
		}
		
		CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
		[coveredShadow addAnimation:keyAnimation forKey:nil];
		[coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];
	}
	
	// shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
	NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat shadowProgress;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
		shadowProgress = (1 - progress) * 8;
		if (shadowProgress > 1)
			shadowProgress = 1;
		
		[arrayOpacity addObject:[NSNumber numberWithFloat:0.5 * shadowProgress]];
	}
	
	CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
	[keyAnimation setCalculationMode:kCAAnimationLinear];
	[keyAnimation setValues:arrayOpacity];
	[layer addAnimation:keyAnimation forKey:nil];
	[layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];
	
	// Commit the transaction
	[CATransaction commit];
}

- (void)startFlipWithDirection:(FlipDirection)aDirection orientation:(FlipOrientation)anOrientation
{
	direction = aDirection;
	orientation = anOrientation;
	[self setFlipFrontPage:YES];
	
	[self buildLayers:aDirection orientation:anOrientation];

	// set the back page in the vertical position (midpoint of animation)
	[self doFlip2:0];
}

- (void)buildLayers:(FlipDirection)aDirection orientation:(FlipOrientation)anOrientation
{
	BOOL forwards = aDirection == FlipDirectionForward;
	BOOL vertical = anOrientation == FlipOrientationVertical;
	BOOL inward = NO;
	
	UIImage *next = forwards? [self nextImage] : [self prevImage];
	CGRect bounds = self.contentView.bounds;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets insets = vertical? UIEdgeInsetsMake(0, 1, 0, 1) : UIEdgeInsetsMake(1, 0, 1, 0);
	
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
	
	// Create 4 images to represent 2 halves of the 2 views
	
	// The page flip animation is broken into 2 halves
	// 1. Flip old page up to vertical
	// 2. Flip new page from vertical down to flat
	// as we pass the halfway point of the animation, the "page" switches from old to new
	
	// front Page  = the half of current view we are flipping during 1st half
	// facing Page = the other half of the current view (doesn't move, gets covered by back page during 2nd half)
	// back Page   = the half of the next view that appears on the flipping page during 2nd half
	// reveal Page = the other half of the next view (doesn't move, gets revealed by front page during 1st half)
	UIImage *pageFrontImage = [MPAnimation renderImageFromView:self.contentView withRect:forwards? lowerRect : upperRect transparentInsets:insets];
	// TODO: facing doesn't need insets
	UIImage *pageFacingImage = [MPAnimation renderImageFromView:self.contentView withRect:forwards? upperRect : lowerRect];
	
	self.imageView.image = next;
	
	UIImage *pageBackImage = [MPAnimation renderImageFromView:self.contentView withRect:forwards? upperRect : lowerRect transparentInsets:insets];
	UIImage *pageRevealImage = [MPAnimation renderImageFromView:self.contentView withRect:forwards? lowerRect : upperRect];
	
	UIView *containerView = [self.contentView superview];
	//[self.contentView setHidden:YES];
	
	CATransform3D transform = CATransform3DIdentity;
	
	CGFloat width = vertical? bounds.size.width : bounds.size.height;
	CGFloat height = vertical? bounds.size.height/2 : bounds.size.width/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	
	// view to hold all our sublayers
	self.animationView = [[UIView alloc] initWithFrame:self.contentView.frame];
	self.animationView.backgroundColor = [UIColor clearColor];
	[containerView insertSubview:self.animationView aboveSubview:self.contentView];
	
	self.layerReveal = [CALayer layer];
	self.layerReveal.frame = (CGRect){CGPointZero, pageRevealImage.size};
	self.layerReveal.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 0 : 1, vertical? forwards? 0 : 1 : 0.5);
	self.layerReveal.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[self.layerReveal setContents:(id)[pageRevealImage CGImage]];
	[self.animationView.layer addSublayer:self.layerReveal];
	
	self.layerFront = [CALayer layer];
	self.layerFront.frame = (CGRect){CGPointZero, pageFrontImage.size};
	self.layerFront.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 0 : 1, vertical? forwards? 0 : 1 : 0.5);
	self.layerFront.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[self.layerFront setContents:(id)[pageFrontImage CGImage]];
	[self.animationView.layer addSublayer:self.layerFront];
	
	self.layerFacing = [CALayer layer];
	self.layerFacing.frame = (CGRect){CGPointZero, pageFacingImage.size};
	self.layerFacing.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 1 : 0, vertical? forwards? 1 : 0 : 0.5);
	self.layerFacing.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[self.layerFacing setContents:(id)[pageFacingImage CGImage]];
	[self.animationView.layer addSublayer:self.layerFacing];
	
	self.layerBack = [CALayer layer];
	self.layerBack.frame = (CGRect){CGPointZero, pageBackImage.size};
	self.layerBack.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 1 : 0, vertical? forwards? 1 : 0 : 0.5);
	self.layerBack.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[self.layerBack setContents:(id)[pageBackImage CGImage]];
	
	// Create shadow layers
	self.layerFrontShadow = [CAGradientLayer layer];
	[self.layerFront addSublayer:self.layerFrontShadow];
	self.layerFrontShadow.frame = CGRectInset(self.layerFront.bounds, insets.left, insets.top);
	self.layerFrontShadow.opacity = 0.0;
	self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
	//self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
	self.layerFrontShadow.startPoint = CGPointMake(0, 0.5);
	self.layerFrontShadow.endPoint = CGPointMake(0.5, 0.5);
	self.layerFrontShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0.1], [NSNumber numberWithDouble:1], nil];
	
	self.layerBackShadow = [CAGradientLayer layer];
	[self.layerBack addSublayer:self.layerBackShadow];
	self.layerBackShadow.frame = CGRectInset(self.layerBack.bounds, insets.left, insets.top);
	self.layerBackShadow.opacity = 0.1;
	self.layerBackShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
	self.layerBackShadow.startPoint = CGPointMake(0.5, 0.5);
	self.layerBackShadow.endPoint = CGPointMake(1, 0.5);
	self.layerBackShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0.9], [NSNumber numberWithDouble:1], nil];
	
	if (!inward)
	{
		self.layerRevealShadow = [CALayer layer];
		[self.layerReveal addSublayer:self.layerRevealShadow];
		self.layerRevealShadow.frame = self.layerReveal.bounds;
		self.layerRevealShadow.backgroundColor = [UIColor blackColor].CGColor;
		self.layerRevealShadow.opacity = 0.5;
		
		self.layerFacingShadow = [CALayer layer];
		//[self.layerFacing addSublayer:self.layerFacingShadow];
		self.layerFacingShadow.frame = self.layerFacing.bounds;
		self.layerFacingShadow.backgroundColor = [UIColor blackColor].CGColor;
		self.layerFacingShadow.opacity = 0.0;
	}
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	transform.m34 = [self skew];
	if (inward)
		transform.m34 = -transform.m34; // flip perspective around
	self.animationView.layer.sublayerTransform = transform;
	
	// set shadows on the 2 pages we'll be animating
	//self.layerFront.shadowOpacity = 0.5;
	self.layerFront.shadowOffset = CGSizeMake(0,3);
	[self.layerFront setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.layerFront bounds], insets.left, insets.top)] CGPath]];	
	self.layerBack.shadowOpacity = 0.5;
	self.layerBack.shadowOffset = CGSizeMake(0,3);
	[self.layerBack setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.layerBack bounds], insets.left, insets.top)] CGPath]];
}

 - (void)doFlip1:(CGFloat)progress
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;

	[self.layerFront setTransform:[self flipTransform1:progress]];
	[self.layerFrontShadow setOpacity:0.1 * progress];
	CGFloat cosOpacity = cos(radians(90 * progress)) * (1./3);
	[self.layerRevealShadow setOpacity:cosOpacity];
	
	// shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
	CGFloat shadowProgress = progress * 8;
	if (shadowProgress > 1)
		shadowProgress = 1;
	[self.layerFront setShadowOpacity:0.5 * shadowProgress];

	[CATransaction commit];
}
 
 - (void)doFlip2:(CGFloat)progress
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;
	
	[self.layerBack setTransform:[self flipTransform2:progress]];
	[self.layerBackShadow setOpacity:0.1 * (1- progress)];
	CGFloat sinOpacity = sin(radians(90 * progress)) * (1./3);
	[self.layerFacingShadow setOpacity:sinOpacity];
	
	// shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
	CGFloat shadowProgress = (1 - progress) * 8;
	if (shadowProgress > 1)
		shadowProgress = 1;
	[self.layerBack setShadowOpacity:0.5 * shadowProgress];

	[CATransaction commit];
}
	 
- (CATransform3D)flipTransform1:(CGFloat)progress
{
	CATransform3D tHalf1 = CATransform3DIdentity;

	// rotate away from viewer
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);
	tHalf1 = CATransform3DRotate(tHalf1, radians(ANGLE * progress * (isForward? -1 : 1)), isVertical? -1 : 0, isVertical? 0 : 1, 0);
	
	return tHalf1;
}

- (CATransform3D)flipTransform2:(CGFloat)progress
{
	CATransform3D tHalf2 = CATransform3DIdentity;

	// rotate away from viewer
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);
	tHalf2 = CATransform3DRotate(tHalf2, radians(ANGLE * (1 - progress)) * (isForward? 1 : -1), isVertical? -1 : 0, isVertical? 0 : 1, 0);

	return tHalf2;
}

- (void)endFlip:(BOOL)completed
{
	// cleanup	
	[self.animationView removeFromSuperview];
	self.animationView = nil;
	self.layerFront = nil;
	self.layerBack = nil;
	self.layerFacing = nil;
	self.layerReveal = nil;
	self.layerFrontShadow = nil;
	self.layerBackShadow = nil;
	self.layerFacingShadow = nil;
	self.layerRevealShadow = nil;
	
	if (completed)
	{
		if (direction == FlipDirectionForward)
			[self setCurrentImageIndex:([self currentImageIndex] + 1) % IMAGE_COUNT];
		else
			[self setCurrentImageIndex:([self currentImageIndex] + IMAGE_COUNT - 1) % IMAGE_COUNT];
	}
	else
		self.imageView.image = [self currentImage];
	
	[self.imageView setHidden:NO];
}

#pragma mark - Slider

- (IBAction)skewValueChanged:(id)sender {
	UISlider *slider = sender;
	self.skewLabel.text = [NSString stringWithFormat:@"%.04f", slider.value];
}

@end
