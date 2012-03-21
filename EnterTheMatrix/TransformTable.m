//
//  TransformTable.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "TransformTable.h"

@interface TransformTable ()

- (void)updateValueAsInt:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset;
- (void)updateValueAsFloat:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset;
- (void)updateValueAsFloat4:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset;
- (void)updateTranslateX:(UIView *)cell;
- (void)updateTranslateY:(UIView *)cell;
- (void)updateTranslate:(UIView *)cell;
- (void)updateScaleX:(UIView *)cell;
- (void)updateScaleY:(UIView *)cell;
- (void)updateScale:(UIView *)cell;
- (void)updateRotationAngle:(UIView *)cell;
- (void)updateRotateX:(UIView *)cell;
- (void)updateRotateY:(UIView *)cell;
- (void)updateRotateZ:(UIView *)cell;
- (void)updateRotate:(UIView *)cell;
- (void)updateSkew:(UIView *)cell;

@end

@implementation TransformTable

@synthesize transform;
@synthesize scaleLocked;
@synthesize threeD;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		scaleLocked = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
		scaleLocked = YES;
    }
    return self;	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setEditing:YES];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	return CGSizeMake(286, ([self is3D]? 15 : 8) * 40);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.transform operationsOrder] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TransformOperation operation = (TransformOperation)[[[self.transform operationsOrder] objectAtIndex:indexPath.row] intValue];
	
	return 40 * (operation == TransformRotate? (self.is3D? 5 : 2) : operation == TransformSkew? 2 : (self.is3D? 4 : 3));
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TranslateCellIdentifier = @"TranslateCell";
    static NSString *ScaleCellIdentifier = @"ScaleCell";
	static NSString *RotateCellIdentifier = @"RotateCell";
    static NSString *SkewCell3DIdentifier = @"SkewCell3D";
    static NSString *TranslateCell3DIdentifier = @"TranslateCell3D";
    static NSString *ScaleCell3DIdentifier = @"ScaleCell3D";
     static NSString *RotateCell3DIdentifier = @"RotateCell3D";
    UITableViewCell *cell = nil;
	
	TransformOperation operation = (TransformOperation)[[[self.transform operationsOrder] objectAtIndex:indexPath.row] intValue];
    // Configure the cell...
    switch (operation) {
		case TransformSkew:
			cell = [tableView dequeueReusableCellWithIdentifier:SkewCell3DIdentifier];
			[self updateSkew:cell];
			break;
			
		case TransformTranslate:
			cell = [tableView dequeueReusableCellWithIdentifier:[self is3D]? TranslateCell3DIdentifier : TranslateCellIdentifier];
			[self updateTranslate:cell];
			break;
			
		case TransformScale:
			cell = [tableView dequeueReusableCellWithIdentifier:[self is3D]? ScaleCell3DIdentifier : ScaleCellIdentifier];
			[self updateScale:cell];
			break;
			
		case TransformRotate:
			cell = [tableView dequeueReusableCellWithIdentifier:[self is3D]? RotateCell3DIdentifier : RotateCellIdentifier];
			[self updateRotate:cell];
			break;
			
		default:
			break;
	}
	
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[self.transform moveOperationAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Touch event handlers

- (IBAction)translateXChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setTranslateX:slider.value];
	
	[self updateTranslateX:[sender superview]];
}

- (IBAction)translateYChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setTranslateY:slider.value];
	
	[self updateTranslateY:[sender superview]];
}

- (IBAction)translateZChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setTranslateZ:slider.value];
	
	[self updateTranslateZ:[sender superview]];
}

- (IBAction)scaleXChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setScaleX:slider.value];
	
	[self updateScaleX:[sender superview]];
	if ([self isScaleLocked])
	{
		[self.transform setScaleY:[self.transform scaleX]];
		[self updateScaleY:[sender superview]];
		
		if ([self is3D])
		{
			[self.transform setScaleZ:[self.transform scaleX]];
			[self updateScaleZ:[sender superview]];			
		}
	}
}

- (IBAction)scaleYChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setScaleY:slider.value];

	[self updateScaleY:[sender superview]];
	if ([self isScaleLocked])
	{
		[self.transform setScaleX:[self.transform scaleY]];
		[self updateScaleX:[sender superview]];
		
		if ([self is3D])
		{
			[self.transform setScaleZ:[self.transform scaleY]];
			[self updateScaleZ:[sender superview]];			
		}
	}
}

- (IBAction)scaleZChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setScaleZ:slider.value];
	
	[self updateScaleZ:[sender superview]];
	if ([self isScaleLocked])
	{
		[self.transform setScaleX:[self.transform scaleZ]];
		[self updateScaleX:[sender superview]];

		[self.transform setScaleY:[self.transform scaleZ]];
		[self updateScaleY:[sender superview]];
	}
}

- (IBAction)rotationAngleChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setRotationAngle:slider.value];
	
	[self updateRotationAngle:[sender superview]];
}

- (IBAction)rotateXChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setRotationX:slider.value];
	
	[self updateRotateX:[sender superview]];
}

- (IBAction)rotateYChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setRotationY:slider.value];
	
	[self updateRotateY:[sender superview]];
}

- (IBAction)rotateZChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setRotationZ:slider.value];
	
	[self updateRotateZ:[sender superview]];
}

- (IBAction)skewChanged:(id)sender {
	UISlider *slider = sender;
	[self.transform setSkew:slider.value];
	[self updateSkew:[sender superview]];
}

- (IBAction)resetTranslatePressed:(id)sender {
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
		[self.transform resetTranslation];
	} completion:nil];	
	[self updateTranslate:[sender superview]];
}

- (IBAction)resetScalePressed:(id)sender {
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
		[self.transform resetScale];
	} completion:nil];	
	[self updateScale:[sender superview]];
}

- (IBAction)resetRotationPressed:(id)sender {
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
		[self.transform resetRotation];
	} completion:nil];	
	[self updateRotate:[sender superview]];
}

- (IBAction)resetSkewPressed:(id)sender {
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
		[self.transform resetSkew];
	} completion:nil];	
	[self updateSkew:[sender superview]];
}

- (IBAction)scaleLockPressed:(id)sender {
	[self setScaleLocked:![self isScaleLocked]];
	UIButton *button = sender;
	[button setImage:[UIImage imageNamed:[self isScaleLocked]? @"Lock" : @"Unlock"] forState:UIControlStateNormal];
	if ([self isScaleLocked])
	{
		[self.transform setScaleY:[self.transform scaleX]];
		[self updateScaleY:[sender superview]];
		if ([self is3D])
		{
			[self.transform setScaleZ:[self.transform scaleX]];
			[self updateScaleZ:[sender superview]];			
		}
	}
}

#pragma mark - Private methods

- (void)updateValueAsInt:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset
{
	UISlider *slider = (UISlider *)[cell viewWithTag:100 + offset];
	[slider setValue:value];
	UILabel *label = (UILabel *)[cell viewWithTag:200 + offset];
	[label setText:[NSString stringWithFormat:@"%d", (int)roundf(value)]];
}

- (void)updateValueAsFloat:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset
{
	UISlider *slider = (UISlider *)[cell viewWithTag:100 + offset];
	[slider setValue:value];
	UILabel *label = (UILabel *)[cell viewWithTag:200 + offset];
	[label setText:[NSString stringWithFormat:@"%.03f", value]];
}

- (void)updateValueAsFloat4:(CGFloat)value forCell:(UIView *)cell withOffset:(NSUInteger)offset
{
	UISlider *slider = (UISlider *)[cell viewWithTag:100 + offset];
	[slider setValue:value];
	UILabel *label = (UILabel *)[cell viewWithTag:200 + offset];
	[label setText:[NSString stringWithFormat:@"%.04f", value]];
}

- (void)updateTranslateX:(UIView *)cell
{
	[self updateValueAsInt:self.transform.translateX forCell:cell withOffset:0];
}

- (void)updateTranslateY:(UIView *)cell
{
	[self updateValueAsInt:self.transform.translateY forCell:cell withOffset:1];
}

- (void)updateTranslateZ:(UIView *)cell
{
	[self updateValueAsInt:self.transform.translateZ forCell:cell withOffset:2];
}

- (void)updateTranslate:(UIView *)cell
{
	[self updateTranslateX:cell];
	[self updateTranslateY:cell];
	if ([self is3D])
		[self updateTranslateZ:cell];
}

- (void)updateScaleX:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.scaleX forCell:cell withOffset:0];
}

- (void)updateScaleY:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.scaleY forCell:cell withOffset:1];
}

- (void)updateScaleZ:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.scaleZ forCell:cell withOffset:2];
}

- (void)updateScale:(UIView *)cell
{
	[self updateScaleX:cell];
	[self updateScaleY:cell];
	if ([self is3D])
		[self updateScaleZ:cell];
}

- (void)updateRotationAngle:(UIView *)cell
{
	[self updateValueAsInt:self.transform.rotationAngle forCell:cell withOffset:0];
}

- (void)updateRotateX:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.rotationX forCell:cell withOffset:1];
}

- (void)updateRotateY:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.rotationY forCell:cell withOffset:2];
}

- (void)updateRotateZ:(UIView *)cell
{
	[self updateValueAsFloat:self.transform.rotationZ forCell:cell withOffset:3];
}

- (void)updateSkew:(UIView *)cell
{
	[self updateValueAsFloat4:self.transform.skew forCell:cell withOffset:0];
}

- (void)updateRotate:(UIView *)cell
{
	[self updateRotationAngle:cell];
	if ([self is3D])
	{
		[self updateRotateX:cell];
		[self updateRotateY:cell];
		[self updateRotateZ:cell];
	}
}

@end
