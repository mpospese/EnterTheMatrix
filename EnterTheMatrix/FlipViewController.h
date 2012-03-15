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
{
	int currentImage;
	FlipDirection direction;
	FlipOrientation orientation;
	
	BOOL isFlipFrontPage;
	BOOL isAnimating;
	BOOL isPanning;
	CGPoint panStart;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISwitch *speedSwitch;
@property (weak, nonatomic) IBOutlet UISlider *skewSlider;
@property (weak, nonatomic) IBOutlet UILabel *skewLabel;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (strong, nonatomic) UIImageView *pageFront;
@property (strong, nonatomic) UIImageView *pageBack;
@property (strong, nonatomic) UIImageView *pageFacing;
@property (readonly) CGFloat skew;

- (IBAction)skewValueChanged:(id)sender;

@end
