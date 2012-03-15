//
//  MPTransform.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/28/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPTransform.h"

@interface MPTransform(Private)

@property (assign, nonatomic) CGAffineTransform affineTransform;
@property (assign, nonatomic) CATransform3D transform3D;

- (void)updateTransform;

@end

@implementation MPTransform

@synthesize translateX;
@synthesize translateY;
@synthesize translateZ;
@synthesize scaleX;
@synthesize scaleY;
@synthesize scaleZ;
@synthesize rotationAngle;
@synthesize rotationX;
@synthesize rotationY;
@synthesize rotationZ;

- (id)init
{
	self = [super init];
	if (self)
	{
		translateX = 0;
		translateY = 0;
		translateZ = 0;
		scaleX = 1;
		scaleY = 1;
		scaleZ = 1;
		rotationAngle = 0;
		rotationX = 0;
		rotationY = 0;
		rotationZ = 1;
		_operationsOrder = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:(int)TransformTranslate], [NSNumber numberWithInt:(int)TransformScale], [NSNumber numberWithInt:(int)TransformRotate], nil];
		_affineTransform = CGAffineTransformIdentity;
		_transform3D = CATransform3DIdentity;
	}
	return self;
}

#pragma mark - Properties

- (CGAffineTransform)affineTransform
{
	return _affineTransform;
}

- (CATransform3D)transform3D
{
	return _transform3D;
}

- (void)setAffineTransform:(CGAffineTransform)value
{
	if (!CGAffineTransformEqualToTransform(_affineTransform, value))
	{
		_affineTransform = value;
	}
}

- (void)setTransform3D:(CATransform3D)value
{
	if (!CATransform3DEqualToTransform(_transform3D, value))
	{
		_transform3D = value;
	}
}

- (NSArray *)operationsOrder
{
	return _operationsOrder;
}

- (void)setTranslateX:(CGFloat)value
{
	if (translateX != value)
	{
		translateX = value;
		[self updateTransform];
	}
}

- (void)setTranslateY:(CGFloat)value
{
	if (translateY != value)
	{
		translateY = value;
		[self updateTransform];
	}
}

- (void)setTranslateZ:(CGFloat)value
{
	if (translateZ != value)
	{
		translateZ = value;
		[self updateTransform];
	}
}

- (void)setScaleX:(CGFloat)value
{
	if (scaleX != value)
	{
		scaleX = value;
		[self updateTransform];
	}
}

- (void)setScaleY:(CGFloat)value
{
	if (scaleY != value)
	{
		scaleY = value;
		[self updateTransform];
	}
}

- (void)setScaleZ:(CGFloat)value
{
	if (scaleZ != value)
	{
		scaleZ = value;
		[self updateTransform];
	}
}

- (void)setRotationAngle:(CGFloat)value
{
	if (rotationAngle != value)
	{
		rotationAngle = value;
		[self updateTransform];
	}
}

- (void)setRotationX:(CGFloat)value
{
	if (rotationX != value)
	{
		rotationX = value;
		[self updateTransform];
	}
}

- (void)setRotationY:(CGFloat)value
{
	if (rotationY != value)
	{
		rotationY = value;
		[self updateTransform];
	}
}

- (void)setRotationZ:(CGFloat)value
{
	if (rotationZ != value)
	{
		rotationZ = value;
		[self updateTransform];
	}
}

#pragma mark - Instance methods

- (void)updateTransform
{
	CGAffineTransform t = CGAffineTransformIdentity;
	CATransform3D t3D = CATransform3DIdentity;
	
	for (NSNumber *opAsNum in _operationsOrder)
	{
		TransformOperation oper = (TransformOperation)[opAsNum intValue];
		switch (oper) {
			case TransformTranslate:
				t = CGAffineTransformTranslate(t, self.translateX, self.translateY);
				t3D = CATransform3DTranslate(t3D, self.translateX, self.translateY, self.translateZ);
				break;
				
			case TransformScale:
				t = CGAffineTransformScale(t, self.scaleX, self.scaleY);
				t3D = CATransform3DScale(t3D, self.scaleX, self.scaleY, self.scaleZ);
				break;
				
			case TransformRotate:
				t = CGAffineTransformRotate(t, radians(self.rotationAngle));
				t3D = CATransform3DRotate(t3D, radians(self.rotationAngle), self.rotationX, self.rotationY, self.rotationZ);
				break;
				
			default:
				break;
		}
	}
	
	[self setAffineTransform:t];
	[self setTransform3D:t3D];
}

- (void)moveOperationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	if (fromIndex == toIndex)
		return;
	
	if (fromIndex >= _operationsOrder.count)
		[NSException raise:NSInvalidArgumentException format:@"From index (%d) out of range", fromIndex];
	if (toIndex >= _operationsOrder.count)
		[NSException raise:NSInvalidArgumentException format:@"To index (%d) out of range", toIndex];
	
	NSNumber *operation = [_operationsOrder objectAtIndex:fromIndex];
	[_operationsOrder removeObjectAtIndex:fromIndex];
	[_operationsOrder insertObject:operation atIndex:toIndex];
	[self updateTransform];
}

- (void)reset
{
	translateX = 0;
	translateY = 0;
	translateZ = 0;
	scaleX = 1;
	scaleY = 1;
	scaleZ = 1;
	rotationAngle = 0;
	rotationX = 0;
	rotationY = 0;
	rotationZ = 1;
	[self setAffineTransform:CGAffineTransformIdentity];
	[self setTransform3D:CATransform3DIdentity];
}

- (void)resetTranslation
{
	translateX = 0;
	translateY = 0;
	translateZ = 0;
	[self updateTransform];
}

- (void)resetScale
{
	scaleX = 1;
	scaleY = 1;
	scaleZ = 1;
	[self updateTransform];
}

- (void)resetRotation
{
	rotationAngle = 0;
	rotationX = 0;
	rotationY = 0;
	rotationZ = 1;
	[self updateTransform];
}

- (CGAffineTransform)affineTransformExcluding:(TransformOperation)operation
{
	CGAffineTransform t = CGAffineTransformIdentity;
	for (NSNumber *opAsNum in _operationsOrder)
	{
		TransformOperation oper = (TransformOperation)[opAsNum intValue];
		if (oper == operation)
			return t;
		
		switch (oper) {
			case TransformTranslate:
				t = CGAffineTransformScale(t, self.translateX, self.translateY);
				break;
				
			case TransformScale:
				t = CGAffineTransformScale(t, self.scaleX, self.scaleY);
				break;
				
			case TransformRotate:
				t = CGAffineTransformRotate(t, radians(self.rotationAngle));
				break;
		}
	}
	
	return t;
}

- (CATransform3D)transform3DExcluding:(TransformOperation)operation
{
	CATransform3D t = CATransform3DIdentity;
	for (NSNumber *opAsNum in _operationsOrder)
	{
		TransformOperation oper = (TransformOperation)[opAsNum intValue];
		if (oper == operation)
			return t;
		
		switch (oper) {
			case TransformTranslate:
				t = CATransform3DTranslate(t, self.translateX, self.translateY, self.translateZ);
				break;
				
			case TransformScale:
				t = CATransform3DScale(t, self.scaleX, self.scaleY, self.scaleZ);
				break;
				
			case TransformRotate:
				t = CATransform3DRotate(t, radians(self.rotationAngle), self.rotationX, self.rotationY, self.rotationZ);
				break;
		}
	}
	
	return t;
}

- (void)offset:(CGPoint)point
{
	// we have a 2D offset vector (x, y) from panning from untransformed user space, that we need to
	// convert into transformed user space to offset the translation correctly.
	// If translation is the first operation, then we're done, but if there's rotation and/or scaling
	// first, then we need to transform our offset
	
	// Get the transformation matrix as it is before we apply translation
	CGAffineTransform t = [self affineTransformExcluding:TransformTranslate];
	// invert it
	CGAffineTransform inv = CGAffineTransformInvert(t);
	// use it to transform our offset vector
	CGPoint transformedPoint = CGPointApplyAffineTransform(point, inv);
	
	// now apply the transformed vector to our translation values
	translateX += transformedPoint.x;
	translateY += transformedPoint.y;
	if (transformedPoint.x != 0 || transformedPoint.y != 0)
		[self updateTransform];
}

- (void)offset3D:(CGPoint)point
{
	// we have a 3D offset vector (x, y, 0) from panning from untransformed user space, that we need to
	// convert into transformed user space to offset the translation correctly.
	// If translation is the first operation, then we're done, but if there's rotation and/or scaling
	// first, then we need to transform our offset
	
	// Get the transformation matrix as it is before we apply translation
	CATransform3D t = [self transform3DExcluding:TransformTranslate];
	// invert it
	CATransform3D inv = CATransform3DInvert(t);

	// Use it to transform our offset vector
	// I couldn't find a 3D analog of CGPointApplyAffineTransform, so I rolled my own:
	CGFloat newX = (point.x * inv.m11) + (point.y * inv.m21) + (0 * inv.m31) + inv.m41;
	CGFloat newY = (point.x * inv.m12) + (point.y * inv.m22) + (0 * inv.m32) + inv.m42;
	CGFloat newZ = (point.x * inv.m13) + (point.y * inv.m23) + (0 * inv.m33) + inv.m43;
	
	// now apply the transformed vector to our translation values
	translateX += newX;
	translateY += newY;
	translateZ += newZ;
	if (newX != 0 || newY != 0 || newZ != 0)
		[self updateTransform];
}

- (void)scaleOffset:(CGFloat)scale
{
	if (scale != 1.0)
	{
		scaleX *= scale;
		scaleY *= scale;
		scaleZ *= scale;
		[self updateTransform];
	}
}

- (void)rotationOffset:(CGFloat)angle
{
	if (angle != 0.0)
	{
		rotationAngle += angle;
		while (rotationAngle > 180)
			rotationAngle -= 360;
		while (rotationAngle < -180)
			rotationAngle += 360;
		[self updateTransform];
	}
}

@end
