//
//  TransformController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransform.h"
#import "AnchorPointTable.h"

#define TRANSLATE_LABEL_TAG				700
#define SCALE_LABEL_TAG					701
#define ROTATE_LABEL_TAG					702
#define TRANSFORM_CONTAINER_TAG			703

@interface TransformController : UIViewController<AnchorPointDelegate>
{
	BOOL _observerAdded;
	CGPoint lastPoint;
	CGFloat lastScale;
	CGFloat lastRotation;
}

@property (strong, nonatomic) MPTransform *transform;
@property(nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (readonly, nonatomic) BOOL is3D;
@property (readonly, nonatomic) NSString *imageName;
@property (assign, nonatomic) AnchorPointLocation anchorPoint;

- (IBAction)transformPressed:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (IBAction)infoPressed:(id)sender;
- (IBAction)anchorPressed:(id)sender;

- (UIView *)makeContainer;
- (void)setText:(NSString *)text forLabel:(UILabel *)label;
- (void)positionLabel:(UILabel *)label aboveGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateTransform;

#pragma mark - AnchorPointDelegate

- (void)anchorPointDidChange:(AnchorPointLocation)newAnchorPoint;

@end
