//
//  InfoView.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/29/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "InfoView.h"

#define LABEL_GAP 20
#define LABEL_WIDTH 200

@interface InfoView ()

@end

@implementation InfoView
@synthesize label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (CGSize)contentSizeForViewInPopover
{
    CGSize size = [[[self label] text] sizeWithFont:[[self label] font] constrainedToSize:CGSizeMake(LABEL_WIDTH, 480) lineBreakMode:UILineBreakModeWordWrap];
    return CGSizeMake(size.width + LABEL_GAP*2, size.height + LABEL_GAP*2);
}

@end
