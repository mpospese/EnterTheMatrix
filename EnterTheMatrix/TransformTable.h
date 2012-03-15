//
//  TransformTable.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransform.h"

@interface TransformTable : UITableViewController

@property (strong, nonatomic) MPTransform* transform;
@property (assign, nonatomic, getter = isScaleLocked) BOOL scaleLocked;
@property (assign, nonatomic, getter = is3D) BOOL threeD;

- (IBAction)translateXChanged:(id)sender;
- (IBAction)translateYChanged:(id)sender;
- (IBAction)translateZChanged:(id)sender;
- (IBAction)scaleXChanged:(id)sender;
- (IBAction)scaleYChanged:(id)sender;
- (IBAction)scaleZChanged:(id)sender;
- (IBAction)rotationAngleChanged:(id)sender;
- (IBAction)rotateXChanged:(id)sender;
- (IBAction)rotateYChanged:(id)sender;
- (IBAction)rotateZChanged:(id)sender;

- (IBAction)resetTranslatePressed:(id)sender;
- (IBAction)resetScalePressed:(id)sender;
- (IBAction)resetRotationPressed:(id)sender;
- (IBAction)scaleLockPressed:(id)sender;

@end
