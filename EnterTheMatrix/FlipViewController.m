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
#define DEFAULT_SKEW	-(1. / 1000.)
#define ANGLE	90
#define MARGIN	72

#define SWIPE_UP_THRESHOLD -1000.0f
#define SWIPE_DOWN_THRESHOLD 1000.0f
#define SWIPE_LEFT_THRESHOLD -1000.0f
#define SWIPE_RIGHT_THRESHOLD 1000.0f

@interface FlipViewController ()

@property(assign, nonatomic) int currentImageIndex;
@property(assign, nonatomic) FlipDirection direction;
@property(assign, nonatomic) FlipOrientation orientation;
@property(assign, nonatomic, getter = isFlipFrontPage) BOOL flipFrontPage;
@property(assign, nonatomic, getter = isAnimating) BOOL animating;
@property(assign, nonatomic, getter = isPanning) BOOL panning;
@property(assign, nonatomic) CGPoint panStart;

@end

@implementation FlipViewController

@synthesize currentImageIndex;
@synthesize direction;
@synthesize orientation;
@synthesize flipFrontPage;
@synthesize animating;
@synthesize panning;
@synthesize panStart;
@synthesize contentView;
@synthesize imageView;
@synthesize speedSwitch;
@synthesize skewSlider;
@synthesize skewLabel;
@synthesize controlFrame;
@synthesize pageFront;
@synthesize pageBack;
@synthesize pageFacing;

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
			if ([self isFlipFrontPage])
			{
				[self doFlip2:0];
			}
			[self.pageFront setHidden:![self isFlipFrontPage]];
			[self.pageBack setHidden:[self isFlipFrontPage]];
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
				// We'll pro-rate the delay for the first half of the animation based on our current position
				CGFloat progress = [self progressFromPosition:currentPosition];
				if (([self isFlipFrontPage] && progress > 1) || (![self isFlipFrontPage] && progress < 1))
					progress = 1;
				NSTimeInterval duration = ([self isFlipFrontPage]? (1- progress) : (progress - 1)) * 0.5 * ([self.speedSwitch isOn]? 1 : 5);

				[UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveLinear animations:^{
					// animate up to middle position
					if (shouldFallBack)
						[self doFlip2:0];
					else
						[self doFlip1:1];
				} completion:^(BOOL finished) {
					// run the 2nd half of the animation
					[self setFlipFrontPage:shouldFallBack];
					self.pageFront.hidden = !shouldFallBack;
					self.pageBack.hidden = shouldFallBack;
					
					[UIView animateWithDuration:[self.speedSwitch isOn]? 0.5 : 2.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
						if (shouldFallBack)
							[self doFlip1:0];
						else
							[self doFlip2:1];
					} completion:^(BOOL finished) {
						
						[self endFlip:!shouldFallBack];
						
						// Clear flags
						[self setAnimating:NO];
						[self setPanning:NO];
					}];
				}];
			}
			else
			{
				// 1-stage animation
				[UIView animateWithDuration:[self.speedSwitch isOn]? 0.5 : 2.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
					if (shouldFallBack)
						[self doFlip1:0];
					else
						[self doFlip2:1];
				} completion:^(BOOL finished) {
					
					[self endFlip:!shouldFallBack];
					
					// Clear flags
					[self setAnimating:NO];
					[self setPanning:NO];
				}];
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
	
	// Figure out how many frames we want
	CGFloat duration = [self.speedSwitch isOn]? 0.5 : 2.5;
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Build an array of keyframes (each a single transform)
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* array2 = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = ((float)frame) / frameCount;
		[array addObject:[NSValue valueWithCATransform3D:[self flipTransform1:progress]]];
		[array2 addObject:[NSValue valueWithCATransform3D:[self flipTransform2:progress]]];
	}
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		// 2nd half of animation, once 1st half completes
		[self setFlipFrontPage:NO];
		self.pageFront.hidden = YES;
		self.pageBack.hidden = NO;
		
		// Create a transaction
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
		[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] forKey:kCATransactionAnimationTimingFunction];
		[CATransaction setCompletionBlock:^{
			// once 2nd half completes
			[self endFlip:YES];
			[self setAnimating:NO];
		}];
		
		// Create the animation
		// (we're animating transform property)
		CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
		// set our keyframe values
		[animation2 setValues:[NSArray arrayWithArray:array2]]; 		
		[animation2 setRemovedOnCompletion:YES];
		
		// add the animation
		[self.pageBack.layer addAnimation:animation2 forKey:@"transform2"];
		// set final state
		NSValue* toValue = [animation2.values lastObject];
		[self.pageBack.layer setTransform:[toValue CATransform3DValue]];
		
		// Commit the transaction
		[CATransaction commit];
	}];
		
	// Create the animation
	// (we're animating transform property)
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	// set our keyframe values
	[animation setValues:[NSArray arrayWithArray:array]]; 		
	[animation setRemovedOnCompletion:YES];
	
	// add the animation
	[self.pageFront.layer addAnimation:animation forKey:@"transform1"];
	// set final state
	NSValue* toValue = [animation.values lastObject];
	[self.pageFront.layer setTransform:[toValue CATransform3DValue]];

	// Commit the transaction
	[CATransaction commit];
}

- (void)startFlipWithDirection:(FlipDirection)aDirection orientation:(FlipOrientation)anOrientation
{
	direction = aDirection;
	orientation = anOrientation;
	[self setFlipFrontPage:YES];
	
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);

	UIImage *next = isForward? [self nextImage] : [self prevImage];
	CGRect rect = self.contentView.bounds;
	CGRect half1Rect = rect;
	if (orientation == FlipOrientationVertical)
		half1Rect.size.height = rect.size.height / 2;
	else
		half1Rect.size.width = rect.size.width / 2;
	CGRect half2Rect = half1Rect;
	if (orientation == FlipOrientationVertical)
		half2Rect.origin.y = half1Rect.size.height;
	else 
		half2Rect.origin.x = half1Rect.size.width;
	
	UIEdgeInsets insets = UIEdgeInsetsMake(isVertical? 0 : 1, isVertical? 1 : 0, isVertical? 0 : 1, isVertical? 1 : 0);
	self.pageFront = [[UIImageView alloc] initWithImage:[MPAnimation renderImageForAntialiasing: [MPAnimation renderImageFromView:self.contentView withRect:isForward? half2Rect : half1Rect] withInsets:insets]];
	self.pageFacing = [[UIImageView alloc] initWithImage:[MPAnimation renderImageForAntialiasing: [MPAnimation renderImageFromView:self.contentView withRect:isForward? half1Rect : half2Rect] withInsets:insets]];
	
	self.imageView.image = next;
	
	self.pageBack = [[UIImageView alloc] initWithImage:[MPAnimation renderImageForAntialiasing: [MPAnimation renderImageFromView:self.contentView withRect:isForward? half1Rect : half2Rect] withInsets:insets]];
	self.pageBack.hidden = YES;
	
	half1Rect = [self.view convertRect:half1Rect fromView:self.contentView];
	half2Rect = [self.view convertRect:half2Rect fromView:self.contentView];
	
	half1Rect = CGRectOffset(half1Rect, isVertical? 0 : half1Rect.size.width/2, isVertical? half1Rect.size.height/2 : 0);
	half2Rect = CGRectOffset(half2Rect, isVertical? 0 : -half1Rect.size.width/2, isVertical? -half1Rect.size.height/2 : 0);

	// account for 1-pixel clear margin we introduced for anti-aliasing
	half1Rect = CGRectInset(half1Rect, -insets.left, -insets.top);
	half2Rect = CGRectInset(half2Rect, -insets.left, -insets.top);
	
	self.pageFront.frame = isForward? half2Rect : half1Rect;
	self.pageBack.frame = isForward? half1Rect : half2Rect;
	self.pageFacing.frame = isForward? half1Rect : half2Rect;
	
	// set anchor point to be along center spine (bottom edge of top half/top edge of bottom half/right edge of left half/left edge of right half)
	self.pageFront.layer.anchorPoint = isVertical? CGPointMake(0.5, isForward? 0 : 1) : CGPointMake(isForward? 0 : 1, 0.5);
	self.pageBack.layer.anchorPoint = isVertical? CGPointMake(0.5, isForward? 1 : 0) : CGPointMake(isForward? 1 : 0, 0.5);
	self.pageFacing.layer.anchorPoint = self.pageBack.layer.anchorPoint;
	
	[self.view addSubview:pageFront];
	[self.view addSubview:pageFacing];
	[self.view addSubview:pageBack ];
	
	// set shadows on the 2 pages we'll be animating
	self.pageFront.layer.shadowOpacity = 0.5;
	self.pageFront.layer.shadowRadius = 1;
	self.pageFront.layer.shadowOffset = isVertical? CGSizeMake(0, isForward? 1 : -1) : CGSizeMake(isForward? 1 : -1, 0);
	[[self.pageFront layer] setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.pageFront bounds], insets.left, insets.top)] CGPath]];	
	self.pageBack.layer.shadowOpacity = 0.5;
	self.pageBack.layer.shadowRadius = 1;
	self.pageBack.layer.shadowOffset = isVertical? CGSizeMake(0, isForward? -1 : 1) : CGSizeMake(isForward? -1 : 1, 0);
	[[self.pageBack layer] setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectInset([self.pageBack bounds], insets.left, insets.top)] CGPath]];	

	// set the back page in the vertical position (midpoint of animation)
	[self doFlip2:0];
}

 - (void)doFlip1:(CGFloat)progress
{
	[self.pageFront.layer setTransform:[self flipTransform1:progress]];
}
 
 - (void)doFlip2:(CGFloat)progress
{
	[self.pageBack.layer setTransform:[self flipTransform2:progress]];
}
	 
- (CATransform3D)flipTransform1:(CGFloat)progress
{
	CATransform3D tHalf1 = CATransform3DIdentity;

	// set skew for perspective
	tHalf1.m34 = [self skew] * sinf(radians(90 * progress));
	// rotate away from viewer
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);
	tHalf1 = CATransform3DRotate(tHalf1, radians(ANGLE * progress * (isForward? -1 : 1)), isVertical? -1 : 0, isVertical? 0 : 1, 0);
	
	return tHalf1;
}

- (CATransform3D)flipTransform2:(CGFloat)progress
{
	CATransform3D tHalf2 = CATransform3DIdentity;

	// set skew for perspective
	tHalf2.m34 = [self skew] * cosf(radians(90 * progress));
	// rotate away from viewer
	BOOL isForward = (direction == FlipDirectionForward);
	BOOL isVertical = (orientation == FlipOrientationVertical);
	tHalf2 = CATransform3DRotate(tHalf2, radians(ANGLE * (1 - progress)) * (isForward? 1 : -1), isVertical? -1 : 0, isVertical? 0 : 1, 0);

	return tHalf2;
}

- (void)endFlip:(BOOL)completed
{
	[self.pageFront removeFromSuperview];
	[self.pageBack removeFromSuperview];
	[self.pageFacing removeFromSuperview];
	self.pageFront = nil;
	self.pageBack = nil;
	self.pageFacing = nil;
	
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
