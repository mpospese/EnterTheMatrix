//
//  TransformController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "TransformController.h"
#import "TransformTable.h"
#import "MPAnimation.h"

#define TRANSFORM_POPOVER_ID	@"TransformPopover"
#define INFO_POPOVER_ID			@"InfoPopover"
#define ANCHOR_POPOVER_ID		@"AnchorPopover"
#define TRANSFORM3D_KEY_PATH	@"transform3D"
#define AFFINE_TRANSFORM_KEY_PATH	@"affineTransform"
#define ANCHOR_DOT_TAG			6000

@interface TransformController()<UIGestureRecognizerDelegate>

@property (assign, nonatomic) int gestureCounter;

@end

@implementation TransformController

@synthesize transform;
@synthesize contentView;
@synthesize toolbar;
@synthesize popover;
@synthesize anchorPoint;
@synthesize gestureCounter = _gestureCounter;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		transform = [[MPTransform alloc] init];
		anchorPoint = AnchorPointCenter;
		if ([self is3D])
			[transform addSkewOperation];
	}
	return self;
}

- (void)dealloc
{
	[self removeObserverForTransform];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addObserverForTransform];
	// Do any additional setup after loading the view.

	// use some image tricks
	UIImage *image = [MPAnimation renderImage:[UIImage imageNamed:[self imageName]] withMargin:10 color:[UIColor whiteColor]];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
	imgView.center = CGPointMake(roundf(CGRectGetMidX(self.view.frame)), roundf(CGRectGetMidY(self.view.frame)));
	[imgView setUserInteractionEnabled:YES];
	[self setContentView:imgView];
	[self.view insertSubview:imgView belowSubview:self.toolbar];

	self.contentView.layer.shadowOpacity = 0.5;
	self.contentView.layer.shadowOffset = CGSizeMake(0, 3);
	[[self.contentView layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.contentView bounds]] CGPath]];

	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	panGesture.delegate = self;
	[self.contentView addGestureRecognizer:panGesture];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
	
	UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	rotateGesture.delegate = self;
	[self.view addGestureRecognizer:rotateGesture];
}

- (void)viewDidUnload
{
	[self removeObserverForTransform];
	[self setPopover:nil];
    [self setContentView:nil];
	[self setToolbar:nil];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), roundf(CGRectGetMidY(self.view.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 502, 382);
	[self updateTransform];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), roundf(CGRectGetMidY(self.view.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 502, 382);
}

#pragma mark - Property

- (BOOL)is3D
{
	return NO;
}

- (NSString *)imageName
{
	return @"matrix_02";
}

- (NSString *)transformKeyPath
{
	return [self is3D]? TRANSFORM3D_KEY_PATH : AFFINE_TRANSFORM_KEY_PATH;
}

#pragma mark - KVO

- (void)addObserverForTransform
{
	if (!_observerAdded)
	{
		[self.transform addObserver:self forKeyPath:[self transformKeyPath] options:NSKeyValueObservingOptionNew context:nil];
		_observerAdded = YES;
	}
}

- (void)removeObserverForTransform
{
	if (_observerAdded)
	{
		[self.transform removeObserver:self forKeyPath:[self transformKeyPath]];
		_observerAdded = NO;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:[self transformKeyPath]])
	{
		[self updateTransform];
	}
}

- (void)setAnchorPoint:(AnchorPointLocation)value
{
	if (anchorPoint != value)
	{
		anchorPoint = value;
		CGPoint point;
		
		switch (anchorPoint) {
			case AnchorPointTopLeft:
				point = CGPointMake(0, 0);
				break;
				
			case AnchorPointTopCenter:
				point = CGPointMake(0.5, 0);
				break;
				
			case AnchorPointTopRight:
				point = CGPointMake(1, 0);
				break;
				
			case AnchorPointMiddleLeft:
				point = CGPointMake(0, 0.5);
				break;
				
			case AnchorPointCenter:
				point = CGPointMake(0.5, 0.5);
				break;
				
			case AnchorPointMiddleRight:
				point = CGPointMake(1, 0.5);
				break;
				
			case AnchorPointBottomLeft:
				point = CGPointMake(0, 1);
				break;
				
			case AnchorPointBottomCenter:
				point = CGPointMake(0.5, 1);
				break;
				
			case AnchorPointBottomRight:
				point = CGPointMake(1, 1);
				break;
				
			default:
				break;
		}
		
		// Animate anchor point change
		
		// Begin transaction
		[CATransaction begin];
		NSTimeInterval duration = 0.5;
		[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
		[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] forKey:kCATransactionAnimationTimingFunction];
		[CATransaction setCompletionBlock:^{
			// clean up anchor point animation
			[self.contentView.layer setAnchorPoint:point];
			[self.contentView.layer removeAnimationForKey:@"anchorPoint"];
		}];
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
		animation.removedOnCompletion = NO;
		animation.fillMode = kCAFillModeForwards; // leave in place (to prevent flicker)
		animation.toValue = [NSValue valueWithCGPoint:point];
			
		// add the animation to the layer
		[self.contentView.layer addAnimation:animation forKey:@"anchorPoint"];
		
		// commit the transaction
		[CATransaction commit];

		// position anchor dot
		UIView *anchorDotView = [self.contentView viewWithTag:ANCHOR_DOT_TAG];
		if (anchorDotView == nil)
		{
			anchorDotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Dot"]];
			anchorDotView.tag = ANCHOR_DOT_TAG;
			[self.contentView addSubview:anchorDotView];
		}
		[anchorDotView.layer setPosition:CGPointMake(1 + point.x * (self.contentView.bounds.size.width - 2), 1 + point.y * (self.contentView.bounds.size.height - 2))];		
	}
}

#pragma mark - Transform

- (void)updateTransform
{
	if ([self is3D])
		[self.contentView.layer setTransform:[self.transform transform3D]];
	else
		[self.contentView setTransform:[self.transform affineTransform]];
}

#pragma mark - Button handlers

- (IBAction)transformPressed:(id)sender {
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    UIViewController *contentController = [storyboard instantiateViewControllerWithIdentifier:TRANSFORM_POPOVER_ID];
	TransformTable *transformTable = (TransformTable *)contentController;
	[transformTable setThreeD:[self is3D]];
	[transformTable setTransform:self.transform];
    popover = [[UIPopoverController alloc] initWithContentViewController:contentController];
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];	
}

- (IBAction)resetPressed:(id)sender {
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
	
	UIView *anchorDotView = [self.contentView viewWithTag:ANCHOR_DOT_TAG];

	NSTimeInterval duration = 0.5;
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
		[self.transform reset];
		[anchorDotView setAlpha:0];
		
		// animate anchor point change
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
		animation.duration = duration;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		animation.removedOnCompletion = NO;
		animation.fillMode = kCAFillModeForwards; // leave in place (to prevent flicker)
		animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
		
		[self.contentView.layer addAnimation:animation forKey:@"anchorPoint"];
	} completion:^(BOOL finished) {
		anchorPoint = AnchorPointCenter;
		[anchorDotView removeFromSuperview];
		
		// clean up anchor point animation
		[self.contentView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
		[self.contentView.layer removeAnimationForKey:@"anchorPoint"];
	}];
}

- (IBAction)infoPressed:(id)sender {
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    UIViewController *contentController = [storyboard instantiateViewControllerWithIdentifier:INFO_POPOVER_ID];
    popover = [[UIPopoverController alloc] initWithContentViewController:contentController];
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];	
}

- (IBAction)anchorPressed:(id)sender {
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    UIViewController *contentController = [storyboard instantiateViewControllerWithIdentifier:ANCHOR_POPOVER_ID];
	AnchorPointTable *anchorTable = (AnchorPointTable *)contentController;
	[anchorTable setAnchorPoint:self.anchorPoint];
	[anchorTable setAnchorPointDelegate:self];
    popover = [[UIPopoverController alloc] initWithContentViewController:contentController];
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];	
}

#pragma mark - Labels

- (void)incrementGestureCounter
{
	[self setGestureCounter:[self gestureCounter] + 1];
}

- (void)decrementGestureCounter
{
	[self setGestureCounter:MAX(0, [self gestureCounter] - 1)];
}

- (UIView *)makeContainer
{
	UIView *view = [self.view viewWithTag:TRANSFORM_CONTAINER_TAG];
	
	if (!view)
	{
		view = [[UIView alloc] init];
		view.backgroundColor = [UIColor whiteColor];
		view.tag = TRANSFORM_CONTAINER_TAG;
		view.layer.cornerRadius = 5;
		view.layer.shadowOffset = CGSizeMake(0, 3);
		view.layer.shadowOpacity = 0.5;
		view.layer.zPosition = 4096; // make sure it stays well above our contentView
		
		UILabel *translateLabel = [self makeLabel:TRANSLATE_LABEL_TAG];
		UILabel *scaleLabel = [self makeLabel:SCALE_LABEL_TAG];
		UILabel *rotateLabel = [self makeLabel:ROTATE_LABEL_TAG];
		
		translateLabel.text = [self translateText];
		[translateLabel sizeToFit];
		scaleLabel.text = [self scaleText];
		[scaleLabel sizeToFit];
		rotateLabel.text = [self rotateText];
		[rotateLabel sizeToFit];
		
		CGFloat scale = [[UIScreen mainScreen] scale];
		CGFloat minWidth = MAX(translateLabel.bounds.size.width, MAX(scaleLabel.bounds.size.width, rotateLabel.bounds.size.width)) + 16;
		CGFloat top = 5;
		translateLabel.frame = CGRectMake(roundf(((minWidth - translateLabel.bounds.size.width) / 2) * scale) / scale, top, translateLabel.bounds.size.width, translateLabel.bounds.size.height);
		top += translateLabel.bounds.size.height + 5;
		scaleLabel.frame = CGRectMake(roundf(((minWidth - scaleLabel.bounds.size.width) / 2) * scale) / scale, top, scaleLabel.bounds.size.width, scaleLabel.bounds.size.height);
		top += scaleLabel.bounds.size.height + 5;
		rotateLabel.frame = CGRectMake(roundf(((minWidth - rotateLabel.bounds.size.width) / 2) * scale) / scale, top, rotateLabel.bounds.size.width, rotateLabel.bounds.size.height);
		top += rotateLabel.bounds.size.height + 5;
		
		view.bounds = CGRectMake(0, 0, minWidth, top);
		[view addSubview:translateLabel];
		[view addSubview:scaleLabel];
		[view addSubview:rotateLabel];
	}
	
	return view;
}

- (UILabel *)makeLabel:(int)tag
{
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	label.font = [UIFont fontWithName:@"Menlo" size:18];
	label.tag = tag;
	return label;
}

- (void)setText:(NSString *)text forLabel:(UILabel *)label
{
	[label setText:text];

	UIView *container = [label superview];
	CGFloat width = 0, bottom = 0;
	for (UILabel *subview in [container subviews])
	{
		[subview sizeToFit];
		width = MAX(width, subview.bounds.size.width);
		bottom = MAX(bottom, subview.frame.origin.y + subview.frame.size.height);
	}
	
	width += 16; bottom += 5;
	
	CGFloat scale = [[UIScreen mainScreen] scale];
	if (((int)roundf(width * scale) % 2) != 0)
		width += (1 / scale);
	if (((int)roundf(bottom * scale) % 2) != 0)
		bottom += (1 / scale);
	label.frame = CGRectMake(roundf(((width - label.bounds.size.width) / 2) * scale) / scale, label.frame.origin.y, label.bounds.size.width, label.bounds.size.height);
	container.bounds = CGRectMake(0, 0, width, bottom);
}

- (void)positionLabel:(UILabel *)label aboveGesture:(UIGestureRecognizer *)gestureRecognizer
{
	// find the uppermost touch
	CGPoint position = [gestureRecognizer locationInView:self.view];
	for (NSUInteger i = 0; i < [gestureRecognizer numberOfTouches];i++)
	{
		CGPoint location = [gestureRecognizer locationOfTouch:i inView:self.view];
		if (location.y < position.y)
			position.y = location.y;
	}
	
	UIView *container = [label superview];
	
	// position label a bit above the uppermost touch (so user's fingers don't obscure it)
	position.y = position.y - 76;
	
	// But keep the label entirely on screen
	if (position.y < container.bounds.size.height / 2)
		position.y = container.bounds.size.height / 2;
	if (position. y > self.view.bounds.size.height - (container.bounds.size.height / 2))
		position.y = self.view.bounds.size.height - (container.bounds.size.height / 2);
	if (position.x < container.bounds.size.width / 2)
		position.x = container.bounds.size.width / 2;
	if (position. x > self.view.bounds.size.width - (container.bounds.size.width / 2))
		position.x = self.view.bounds.size.width - (container.bounds.size.width / 2);
	
	container.center = position;
	[[container layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[container bounds] cornerRadius:5] CGPath]];	
}

- (void)setGesture:(UIGestureRecognizer *)gestureRecognizer translationforLabel:(UILabel *)label
{
	NSString *labelText = [self translateText];
	[self setText:labelText forLabel:label];
	if (gestureRecognizer)
		[self positionLabel:label aboveGesture:gestureRecognizer];
}

- (void)setGesture:(UIGestureRecognizer *)gestureRecognizer scaleforLabel:(UILabel *)label
{
	NSString *labelText = [self scaleText];
	[self setText:labelText forLabel:label];
	if (gestureRecognizer)
		[self positionLabel:label aboveGesture:gestureRecognizer];
}

- (void)setGesture:(UIGestureRecognizer *)gestureRecognizer rotationforLabel:(UILabel *)label
{
	NSString *labelText = [self rotateText];
	[self setText:labelText forLabel:label];
	if (gestureRecognizer)
		[self positionLabel:label aboveGesture:gestureRecognizer];
}

- (NSString *)translateText
{
	return [self is3D]? [NSString stringWithFormat:@"Translation {%d, %d, %d}", (int)roundf(self.transform.translateX), (int)roundf(self.transform.translateY), (int)roundf(self.transform.translateZ)] : [NSString stringWithFormat:@"Translation {%d, %d}", (int)roundf(self.transform.translateX), (int)roundf(self.transform.translateY)];
}

- (NSString *)scaleText
{
	return [self is3D]? [NSString stringWithFormat:@"Scale {%.03f, %.03f, %.03f}", self.transform.scaleX, self.transform.scaleY, self.transform.scaleZ] : [NSString stringWithFormat:@"Scale {%.03f, %.03f}", self.transform.scaleX, self.transform.scaleY];
}

- (NSString *)rotateText
{
	return [self is3D]? [NSString stringWithFormat:@"Rotation %d° about vector {%.03f, %.03f, %.03f}",(int)roundf(self.transform.rotationAngle), self.transform.rotationX, self.transform.rotationY, self.transform.rotationZ] : [NSString stringWithFormat:@"Rotation %d°", (int)roundf(self.transform.rotationAngle)];
}

#pragma mark - Gesture Recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
	CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
	UIGestureRecognizerState state = [gestureRecognizer state];
	
	if (state == UIGestureRecognizerStateBegan)
	{
		[self incrementGestureCounter];
		UIView *container = [self makeContainer];
		UILabel *label = (UILabel *)[container viewWithTag:TRANSLATE_LABEL_TAG];
		[self positionLabel:label aboveGesture:gestureRecognizer];
		[self.view addSubview:container];
	}
	else if (state == UIGestureRecognizerStateChanged)
	{
		CGPoint diff = CGPointMake(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y);
		if ([self is3D])
			[self.transform offset3D:diff];
		else
			[self.transform offset:diff];
		[self updateTransform];
		
		UILabel *label = (UILabel *)[self.view viewWithTag:TRANSLATE_LABEL_TAG];
		[self setGesture:gestureRecognizer translationforLabel:label];
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		// hide tip when last gesture recognizer ends
		[self decrementGestureCounter];
		if ([self gestureCounter] <= 0)
			[[self.view viewWithTag:TRANSFORM_CONTAINER_TAG] removeFromSuperview];
	}
	
	lastPoint = currentPoint;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
	CGFloat currentScale = [gestureRecognizer scale];
	//CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
	UIGestureRecognizerState state = [gestureRecognizer state];
	
	if (state == UIGestureRecognizerStateBegan)
	{
		[self incrementGestureCounter];
		UIView *container = [self makeContainer];
		UILabel *label = (UILabel *)[container viewWithTag:SCALE_LABEL_TAG];
		[self positionLabel:label aboveGesture:gestureRecognizer];
		[self.view addSubview:container];
	}
	else if (state == UIGestureRecognizerStateChanged)
	{
		CGFloat scaleDiff = currentScale / lastScale;
		[self.transform scaleOffset:scaleDiff];
		[self updateTransform];
		
		UILabel *label = (UILabel *)[self.view viewWithTag:SCALE_LABEL_TAG];
		[self setGesture:gestureRecognizer scaleforLabel:label];
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		// hide tip when last gesture recognizer ends
		[self decrementGestureCounter];
		if ([self gestureCounter] <= 0)
			[[self.view viewWithTag:TRANSFORM_CONTAINER_TAG] removeFromSuperview];
	}
	
	lastScale = currentScale;
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
	CGFloat currentRotation = [gestureRecognizer rotation];
	//CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
	UIGestureRecognizerState state = [gestureRecognizer state];
	
	if (state == UIGestureRecognizerStateBegan)
	{
		[self incrementGestureCounter];
		UIView *container = [self makeContainer];
		UILabel *label = (UILabel *)[container viewWithTag:ROTATE_LABEL_TAG];
		[self positionLabel:label aboveGesture:gestureRecognizer];
		[self.view addSubview:container];
	}
	else if (state == UIGestureRecognizerStateChanged)
	{
		CGFloat rotationDiff = degrees(currentRotation - lastRotation);
		[self.transform rotationOffset:rotationDiff];
		[self updateTransform];
		
		UILabel *label = (UILabel *)[self.view viewWithTag:ROTATE_LABEL_TAG];
		[self setGesture:gestureRecognizer rotationforLabel:label];
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		// hide tip when last gesture recognizer ends
		[self decrementGestureCounter];
		if ([self gestureCounter] <= 0)
			[[self.view viewWithTag:TRANSFORM_CONTAINER_TAG] removeFromSuperview];
	}
	
	lastRotation = currentRotation;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark - AnchorPointDelegate

- (void)anchorPointDidChange:(AnchorPointLocation)newAnchorPoint
{
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
	
	[self setAnchorPoint:newAnchorPoint];
}

@end
