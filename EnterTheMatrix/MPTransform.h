//
//  MPTransform.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/28/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <QuartzCore/QuartzCore.h>

@interface MPTransform : NSObject
{
	CGAffineTransform _affineTransform;
	CATransform3D _transform3D;
	
	NSMutableArray *_operationsOrder;
}

@property (assign, nonatomic) CGFloat translateX;
@property (assign, nonatomic) CGFloat translateY;
@property (assign, nonatomic) CGFloat translateZ;
@property (assign, nonatomic) CGFloat scaleX;
@property (assign, nonatomic) CGFloat scaleY;
@property (assign, nonatomic) CGFloat scaleZ;
@property (assign, nonatomic) CGFloat rotationAngle;
@property (assign, nonatomic) CGFloat rotationX;
@property (assign, nonatomic) CGFloat rotationY;
@property (assign, nonatomic) CGFloat rotationZ;
@property (nonatomic, readonly) NSArray* operationsOrder;
@property (nonatomic, readonly) CGAffineTransform affineTransform;
@property (nonatomic, readonly) CATransform3D transform3D;

- (void)moveOperationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)reset;
- (void)resetTranslation;
- (void)resetScale;
- (void)resetRotation;
- (void)offset:(CGPoint)point;
- (void)offset3D:(CGPoint)point;
- (void)scaleOffset:(CGFloat)scale;
- (void)rotationOffset:(CGFloat)angle;

@end
