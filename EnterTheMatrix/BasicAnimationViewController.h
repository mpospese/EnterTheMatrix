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

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegment;
@property (weak, nonatomic) IBOutlet UISwitch *speedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *translateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rotateSwitch;
@property (weak, nonatomic) IBOutlet UIView *bar;
@property (weak, nonatomic) IBOutlet UILabel *translateLabel;
@property (weak, nonatomic) IBOutlet UILabel *scaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rotateLabel;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (assign, nonatomic) OrientationMode orientation;
@property (readonly, nonatomic) BOOL isFast;
@property (readonly, nonatomic) BOOL useTranslate;
@property (readonly, nonatomic) BOOL useScale;
@property (readonly, nonatomic) BOOL useRotate;
@property (readonly, nonatomic) AnimationMode animation;

- (IBAction)goPressed:(id)sender;
- (IBAction)animationChanged:(id)sender;

@end
