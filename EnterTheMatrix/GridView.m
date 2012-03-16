//
//  GridView.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "GridView.h"

@implementation GridView

@synthesize lineColor;
@synthesize translateHorz;
@synthesize translateVert;
@synthesize scaleHorz;
@synthesize scaleVert;
@synthesize rotateHorz;
@synthesize rotateVert;

- (void)doInit
{
	lineColor = [UIColor whiteColor];
	translateHorz = 32;
	translateVert = 32;
	scaleHorz = 1;
	scaleVert = 1;
	rotateHorz = 0;
	rotateVert = 0;
}

- (id)init
{
    self = [super init];
    if (self) {
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self doInit];
    }
	
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// vertical lines
	UIBezierPath* vertLine = [UIBezierPath bezierPath];
	[vertLine moveToPoint:CGPointMake(0, 0)];
	[vertLine addLineToPoint:CGPointMake(0, self.bounds.size.height)];
	[vertLine setLineWidth:1];
	
	CGContextSaveGState(context);
	CGFloat offset = [self translateVert];
	CGContextTranslateCTM(context, [self translateVert]-0.5, 0);
	
	[[self lineColor] set];
	
	while (offset <= self.bounds.size.width)
	{
		[vertLine stroke];
		
		CGContextTranslateCTM(context, [self translateVert], 0);
		CGContextRotateCTM(context, radians([self rotateVert]));
		CGContextScaleCTM(context, [self scaleVert], [self scaleVert]);
		offset += [self translateVert];
	}

	CGContextRestoreGState(context);
	CGContextSaveGState(context);
	
	// horizontal lines
	[[self lineColor] setStroke];
	UIBezierPath* horzLine = [UIBezierPath bezierPath];
	[horzLine moveToPoint:CGPointMake(0, 0)];
	[horzLine addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
	[horzLine setLineWidth:1];

	offset = [self translateHorz];
	CGContextTranslateCTM(context, 0, [self translateHorz]-0.5);
	
	[[self lineColor] set];
	
	while (offset <= self.bounds.size.height)
	{
		[horzLine stroke];
		
		CGContextTranslateCTM(context, 0, [self translateHorz]);
		CGContextRotateCTM(context, radians([self rotateHorz]));
		CGContextScaleCTM(context, [self scaleHorz], [self scaleHorz]);
		offset += [self translateHorz];
	}
	
	CGContextRestoreGState(context);
}

- (void)setTranslateHorz:(NSUInteger)value
{
	if (value == 0)
		value = 1;
	
	if (translateHorz != value)
	{
		translateHorz = value;
		[self setNeedsDisplay];
	}
}

- (void)setTranslateVert:(NSUInteger)value
{
	if (value == 0)
		value = 1;
	
	if (translateVert != value)
	{
		translateVert = value;
		[self setNeedsDisplay];
	}
}

- (void)setScaleHorz:(CGFloat)value
{
	if (scaleHorz != value)
	{
		scaleHorz = value;
		[self setNeedsDisplay];
	}
}

- (void)setScaleVert:(CGFloat)value
{
	if (scaleVert != value)
	{
		scaleVert = value;
		[self setNeedsDisplay];
	}
}

- (void)setRotateHorz:(CGFloat)value
{
	if (rotateHorz != value)
	{
		rotateHorz = value;
		[self setNeedsDisplay];
	}
}

- (void)setRotateVert:(CGFloat)value
{
	if (rotateVert != value)
	{
		rotateVert = value;
		[self setNeedsDisplay];
	}
}

- (void)reset
{
	[self setTranslateHorz:16];
	[self setTranslateVert:16];
	[self setScaleHorz:1];
	[self setScaleVert:1];
	[self setRotateHorz:0];
	[self setRotateVert:0];
}

@end
