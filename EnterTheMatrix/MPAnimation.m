//
//  MPAnimation.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPAnimation

+ (UIImage*)renderImageFromView:(UIView *)view withRect:(CGRect)frame
{
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    //UIGraphicsBeginImageContext(frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Translate it, to the desired position
    //CGContextScaleCTM(context, 1.0f, 1.0f );
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    
    // Render the view as image
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

@end
