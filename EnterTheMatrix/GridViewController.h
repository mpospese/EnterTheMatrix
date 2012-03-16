//
//  GridViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/5/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"

@interface GridViewController : UIViewController

@property (weak, nonatomic) IBOutlet GridView *grid;
@property (weak, nonatomic) IBOutlet UIView *horizontalPanel;
@property (weak, nonatomic) IBOutlet UIView *verticalPanel;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (assign, nonatomic, getter = isLocked) BOOL locked;

- (IBAction)translateHorzChanged:(id)sender;
- (IBAction)scaleHorzChanged:(id)sender;
- (IBAction)rotateHorzChanged:(id)sender;
- (IBAction)translateVertChanged:(id)sender;
- (IBAction)scaleVertChanged:(id)sender;
- (IBAction)rotateVertChanged:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (IBAction)lockPressed:(id)sender;

@end
