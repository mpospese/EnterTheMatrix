//
//  Arc.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/11/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "Arc.h"

#define DEFAULT_RADIUS  444
#define DEFAULT_ARC_WIDTH   120
#define DEFAULT_ARC_OPACITY 1.00
#define DEFAULT_ITEM_GAP    20
#define GRADIENT_LIGHT_ANGLE 115
#define DEFAULT_CAROUSEL_HEIGHT 132
#define HORZ_GAP 10

@implementation Arc
@synthesize radius;
@synthesize arcWidth;
@synthesize arcOpacity;
@synthesize color;
@synthesize highlightColor;

- (void)doInit
{
	radius = DEFAULT_RADIUS;
	arcWidth = DEFAULT_ARC_WIDTH;
	arcOpacity = DEFAULT_ARC_OPACITY;
	color = [UIColor colorWithRed:56./255 green:84./255 blue:135./255 alpha:1.0];
	highlightColor = [UIColor colorWithRed:155./255 green:169./255 blue:195./255 alpha:1.0];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self doInit];
    }
    return self;    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self doInit];
    }
    return self;
}

#pragma mark - Properties

- (CGFloat)innerRadius
{
    return self.radius - self.arcWidth;
}

- (CGFloat)midRadius
{
    return self.radius - (self.arcWidth / 2);
}

- (CGFloat)outerRadius
{
    return self.radius;
}

- (CGPoint)arCenter
{
	return CGPointMake(self.bounds.size.width - self.arcWidth / 2, self.bounds.size.height - self.arcWidth / 2);
}

- (CGPathRef)newArcPath
{
    CGFloat innerRadius = [self innerRadius];
    CGFloat outerRadius = [self outerRadius];
    CGRect bounds = self.bounds;
    
    // get the current graphics context
    CGPoint center = [self arCenter];
    
    // build our arc shape
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, center.x, center.y, outerRadius, radians(-180), radians(-90), NO);
	CGPathAddLineToPoint(path, nil, bounds.size.width, bounds.size.height - self.arcWidth/2 - self.midRadius);
	CGPathAddLineToPoint(path, nil,bounds.size.width - self.arcWidth / 2, bounds.size.height - self.arcWidth/2 - innerRadius);
    CGPathAddArc(path, nil, center.x, center.y, innerRadius, radians(-90), radians(-180), YES);
	CGPathAddLineToPoint(path, nil, bounds.size.width - self.arcWidth/2 - self.midRadius, bounds.size.height);
	CGPathAddLineToPoint(path, nil,bounds.size.width - self.arcWidth / 2 - outerRadius, bounds.size.height - self.arcWidth/2);
    
    return path;
    //CGPathRef fixedPath = CGPathCreateCopy(path);
    //CGPathRelease(path);
    //return fixedPath;
}

- (CGColorRef)newColorFromSpace:(CGColorSpaceRef)colorSpace color1:(CGColorRef)color1 color2:(CGColorRef)color2
{
    const CGFloat* components1 = CGColorGetComponents(color1);
    const CGFloat* components2 = CGColorGetComponents(color2);
    int numberOfComponents1 = CGColorGetNumberOfComponents(color1);
    int numberOfComponents2 = CGColorGetNumberOfComponents(color2);
    if (numberOfComponents1 != numberOfComponents2) {
        [NSException raise:@"Diffferent color spaces" format:@"Color 1 has %d color components, but Color 2 has %d color components", numberOfComponents1, numberOfComponents2];
    }
    CGFloat midComponents[numberOfComponents1];
    for (int i = 0; i < numberOfComponents1; i++)
        midComponents[i] = (components1[i] + components2[i])/2.0;
    return CGColorCreate(colorSpace, midComponents);
}

- (void)layoutSubviews
{
	CGRect bounds = self.bounds;
	
	self.radius = MIN(bounds.size.width, bounds.size.height) - self.arcWidth / 2;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // draw arc segment as it intersects screen
    // need to determine angle theta as well as height of the arc segment
    CGFloat innerRadius = [self innerRadius];
    CGFloat outerRadius = [self outerRadius];
    CGRect bounds = self.bounds;
    
    // get the current graphics context
    CGPoint center = [self arCenter];
    
    CGPoint innerTop = CGPointMake(bounds.size.width - self.arcWidth / 2, bounds.size.height - self.arcWidth/2 - innerRadius);
    CGPoint innerBottom = CGPointMake(bounds.size.width - self.arcWidth / 2 - innerRadius, bounds.size.height - self.arcWidth/2);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // build our arc shape
    CGPathRef path = [self newArcPath];
    CGContextAddPath(context, path);
    
    // create our colors and gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 0.25, 0.75,  1.0 };
    
	CGFloat midColorComponents[] = { 0, 0, 0, 1 };
	CGFloat endColorComponents[] = { 0, 0, .75, 1 };
	
	CGColorRef cgMidColor = CGColorCreate(colorSpace, midColorComponents);
	CGColorRef cgEndColor = CGColorCreate(colorSpace, endColorComponents);
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)cgEndColor, (__bridge id)cgMidColor, (__bridge id)cgMidColor, (__bridge id)cgEndColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
                                                        (__bridge CFArrayRef) colors, locations);

    /*CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0, 0.2, 1.0 };
    
    CGColorRef startColor = [[[self highlightColor] colorWithAlphaComponent:self.arcOpacity] CGColor];
    CGColorRef endColor = [[[self color] colorWithAlphaComponent:self.arcOpacity] CGColor];
    const CGFloat* components = CGColorGetComponents(endColor);
    CGFloat midComponents[4];
    for (int i = 0; i < 3; i++)
        midComponents[i] = (components[i] + 1.0)/2.0;
    midComponents[3] = self.arcOpacity;
    CGColorRef midColor = [self newColorFromSpace:colorSpace color1:startColor color2:endColor];
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor, (__bridge id)midColor, (__bridge id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
                                                        (__bridge CFArrayRef) colors, locations);*/
    
    // clip context to our shape, then draw gradient
    CGContextClip(context);
    CGFloat lightSourceRadians = radians(GRADIENT_LIGHT_ANGLE);
    CGPoint startPoint = CGPointMake(bounds.origin.x + outerRadius*cos(-lightSourceRadians) + center.x, bounds.origin.y + outerRadius*sin(-lightSourceRadians) + center.y);
    // end point of gradient- at intersection of line from startPoint to center and line from innerTop to innerBottom
    CGFloat A1 = startPoint.y-center.y;
    CGFloat B1 = center.x-startPoint.x;
    CGFloat C1 = A1*center.x+B1*center.y;
    CGFloat A2 = (innerTop.y + center.y) - (innerBottom.y + center.y);
    CGFloat B2 = (innerBottom.x + center.x)-(innerTop.x + center.x);
    CGFloat C2 = A2*(innerBottom.x + center.x)+B2*(innerBottom.y + center.y);
    double det = A1*B2 - A2*B1;
    CGPoint endPoint = CGPointMake((B2*C1 - B1*C2)/det, (A1*C2 - A2*C1)/det);
    //CGPoint startPoint = CGPointMake(bounds.origin.x, bounds.origin.y);
    //CGPoint endPoint = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    // cleanup
    CGContextRestoreGState(context); // Important! remove the clipping
    CGPathRelease(path);
    //CGColorRelease(midColor);
	CGColorRelease(cgEndColor);
	CGColorRelease(cgMidColor);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}


@end
