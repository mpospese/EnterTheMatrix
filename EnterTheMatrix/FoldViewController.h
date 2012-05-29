//
//  FoldViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoldViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *centerBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *skewSegment;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (readonly) CGFloat skew;

- (void)handlePinch:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)skewValueChanged:(UISegmentedControl *)sender;

@end
