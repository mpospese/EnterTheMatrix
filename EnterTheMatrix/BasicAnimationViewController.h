//
//  BasicAnimationViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
	OrientationLeft,
	OrientationTop,
	OrientationRight,
	OrientationBottom
} OrientationMode;

typedef enum
{
	AnimationFrame,
	AnimationTransform
} AnimationMode;

@interface BasicAnimationViewController : UIViewController

@end
