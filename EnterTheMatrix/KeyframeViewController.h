//
//  KeyframeViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Arc.h"

typedef enum
{
	AnimationModeBasic,
	AnimationModeKeyframe
} AnimationMode;

typedef enum
{
	ArcPositionDown,
	ArcPositionMid,
	ArcPositionUp
} ArcPosition;

@interface KeyframeViewController : UIViewController
{
	ArcPosition arcPosition;
	BOOL movingUp;
}

@property (weak, nonatomic) IBOutlet Arc *arc;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UISwitch *speedSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *arcPositionSegment;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

- (IBAction)arcPositionValueChanged:(id)sender;

@end
