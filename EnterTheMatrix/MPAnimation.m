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

+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame
{
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
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

+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets
{
	CGSize imageSizeWithBorder = CGSizeMake([image size].width + insets.left + insets.right, [image size].height + insets.top + insets.bottom);
	
	// Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, NO, 0);
	
	// The image starts off filled with clear pixels, so we don't need to explicitly fill them here	
	[image drawInRect:(CGRect){{insets.left, insets.top}, [image size]}];
	
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return renderedImage;
}

+ (UIImage *)renderImageForAntialiasing:(UIImage *)image
{
	CGSize imageSizeWithBorder = CGSizeMake([image size].width + 2, [image size].height + 2);
	
	// Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, NO, 0);
	
	// The image starts off filled with clear pixels, so we don't need to explicitly fill them here	
	[image drawInRect:(CGRect){{1, 1}, [image size]}];
	
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return renderedImage;
}

+ (UIImage *)renderImage:(UIImage *)image withMargin:(CGFloat)width color:(UIColor *)color
{
	CGSize imageSizeWithBorder = CGSizeMake([image size].width + 2 * (width + 1), [image size].height + 2 * (width + 1));
	
	// Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, NO, 0);
	
	// The image starts off filled with clear pixels, so we don't need to explicitly fill them here.
	CGRect rect = CGRectMake(1, 1, [image size].width + 2 * width, [image size].height + 2 * width);
	[color set];
	UIRectFill(rect);
	
	[image drawInRect:(CGRect){{width + 1, width + 1}, [image size]}];

    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return renderedImage;
}

@end
