//
//  GridViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/5/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController
@synthesize grid;
@synthesize horizontalPanel;
@synthesize verticalPanel;
@synthesize lockButton;
@synthesize resetButton;
@synthesize locked;

- (void)doInit
{
	locked = YES;
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

- (id)init
{
    self = [super init];
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
	view.layer.cornerRadius = 5;
	view.layer.shadowOpacity = 0.5;
	view.layer.shadowOffset = CGSizeMake(0, 3);
	[self setShadowPathOnView:view];
}

- (void)setShadowPathOnView:(UIView *)view
{
	[[view layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[view bounds] cornerRadius:5] CGPath]];	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self addDropShadowToView:self.horizontalPanel];
	[self addDropShadowToView:self.verticalPanel];
	[self addDropShadowToView:self.lockButton];
	[self addDropShadowToView:self.resetButton];
}

- (void)viewDidUnload
{
	[self setGrid:nil];
    [self setHorizontalPanel:nil];
    [self setVerticalPanel:nil];
	[self setLockButton:nil];
	[self setResetButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)translateHorzChanged:(id)sender {
	UISlider *slider = sender;
	NSUInteger translate = roundf(slider.value);
	[[self grid] setTranslateHorz:translate];
	[self updateTranslateHorz];
	
	if ([self isLocked])
	{
		[[self grid] setTranslateVert:[[self grid] translateHorz]];
		[self updateTranslateVert];
	}
}

- (IBAction)scaleHorzChanged:(id)sender {
	UISlider *slider = sender;
	[[self grid] setScaleHorz:slider.value];
	[self updateScaleHorz];
	
	if ([self isLocked])
	{
		[[self grid] setScaleVert:[[self grid] scaleHorz]];
		[self updateScaleVert];
	}
}

- (IBAction)rotateHorzChanged:(id)sender {
	UISlider *slider = sender;
	[[self grid] setRotateHorz:slider.value];
	[self updateRotateHorz];
	
	if ([self isLocked])
	{
		[[self grid] setRotateVert:[[self grid] rotateHorz]];
		[self updateRotateVert];
	}
}

- (IBAction)translateVertChanged:(id)sender {
	UISlider *slider = sender;
	NSUInteger translate = roundf(slider.value);
	[[self grid] setTranslateVert:translate];
	[self updateTranslateVert];
	
	if ([self isLocked])
	{
		[[self grid] setTranslateHorz:[[self grid] translateVert]];
		[self updateTranslateHorz];
	}
}

- (IBAction)scaleVertChanged:(id)sender {
	UISlider *slider = sender;
	[[self grid] setScaleVert:slider.value];
	[self updateScaleVert];
	
	if ([self isLocked])
	{
		[[self grid] setScaleHorz:[[self grid] scaleVert]];
		[self updateScaleHorz];
	}
}

- (IBAction)rotateVertChanged:(id)sender {
	UISlider *slider = sender;
	[[self grid] setRotateVert:slider.value];
	[self updateRotateVert];
	
	if ([self isLocked])
	{
		[[self grid] setRotateHorz:[[self grid] rotateVert]];
		[self updateRotateHorz];
	}
}

- (IBAction)resetPressed:(id)sender {
	[[self grid] reset];
	[self updateTranslateHorz];
	[self updateTranslateVert];
	[self updateScaleHorz];
	[self updateScaleVert];
	[self updateRotateHorz];
	[self updateRotateVert];
}

- (IBAction)lockPressed:(id)sender {
	[self setLocked:![self isLocked]];
	UIButton *button = sender;
	[button setImage:[UIImage imageNamed:[self isLocked]? @"Lock" : @"Unlock"] forState:UIControlStateNormal];
	if ([self isLocked])
	{
		[[self grid] setTranslateVert:[[self grid] translateHorz]];
		[[self grid] setScaleVert:[[self grid] scaleHorz]];
		[[self grid] setRotateVert:[[self grid] rotateHorz]];
		[self updateTranslateVert];
		[self updateScaleVert];
		[self updateRotateVert];
	}
}

- (void)updateValueAsInt:(CGFloat)value withOffset:(NSUInteger)offset
{
	UISlider *slider = (UISlider *)[self.view viewWithTag:100 + offset];
	[slider setValue:value];
	UILabel *label = (UILabel *)[self.view viewWithTag:200 + offset];
	[label setText:[NSString stringWithFormat:@"%d", (int)roundf(value)]];
}

- (void)updateValueAsFloat:(CGFloat)value withOffset:(NSUInteger)offset
{
	UISlider *slider = (UISlider *)[self.view viewWithTag:100 + offset];
	[slider setValue:value];
	UILabel *label = (UILabel *)[self.view viewWithTag:200 + offset];
	[label setText:[NSString stringWithFormat:@"%.03f", value]];
}

- (void)updateTranslateHorz
{
	[self updateValueAsInt:[[self grid] translateHorz] withOffset:0];
}

- (void)updateTranslateVert
{
	[self updateValueAsInt:[[self grid] translateVert] withOffset:3];
}

- (void)updateScaleHorz
{
	[self updateValueAsFloat:[[self grid] scaleHorz] withOffset:1];
}

- (void)updateScaleVert
{
	[self updateValueAsFloat:[[self grid] scaleVert] withOffset:4];
}

- (void)updateRotateHorz
{
	[self updateValueAsFloat:[[self grid] rotateHorz] withOffset:2];
}

- (void)updateRotateVert
{
	[self updateValueAsFloat:[[self grid] rotateVert] withOffset:5];
}

@end
