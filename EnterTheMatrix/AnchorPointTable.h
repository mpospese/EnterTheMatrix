//
//  AnchorPointTable.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/24/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnchorPointDelegate;
@interface AnchorPointTable : UITableViewController

@property(assign, nonatomic) AnchorPointLocation anchorPoint;
@property(weak, nonatomic) id<AnchorPointDelegate> anchorPointDelegate;

@end

@protocol AnchorPointDelegate <NSObject>

- (void)anchorPointDidChange:(AnchorPointLocation)newAnchorPoint;

@end
