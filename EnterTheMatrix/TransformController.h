//
//  TransformController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransform.h"

#define TRANSFORM_LABEL_TAG				700
#define TRANSFORM_CONTAINER_TAG			701

@interface TransformController : UIViewController
{
	BOOL _observerAdded;
	CGPoint lastPoint;
	CGFloat lastScale;
	CGFloat lastRotation;
}

@property (strong, nonatomic) MPTransform *transform;
@property(nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (readonly, nonatomic) BOOL is3D;
@property (readonly, nonatomic) NSString *imageName;

- (IBAction)transformPressed:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (IBAction)infoPressed:(id)sender;

- (UIView *)makeContainer;
- (UILabel *)makeLabel;
- (void)setText:(NSString *)text forLabel:(UILabel *)label;
- (void)positionLabel:(UILabel *)label aboveGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateTransform;
@end
