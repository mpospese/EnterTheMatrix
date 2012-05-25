//
//  FlipViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	FlipOrientationVertical,
	FlipOrientationHorizontal
} FlipOrientation;

typedef enum {
	FlipDirectionForward,
	FlipDirectionBackward
} FlipDirection;

@interface FlipViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *skewSlider;
@property (weak, nonatomic) IBOutlet UILabel *skewLabel;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (readonly, nonatomic) CGFloat durationMultiplier;
@property (readonly, nonatomic) CGFloat skewMultiplier;

- (IBAction)skewValueChanged:(id)sender;
- (IBAction)durationValueChanged:(id)sender;

@end
