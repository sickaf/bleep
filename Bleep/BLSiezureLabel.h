//
//  BLSiezureLabel.h
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/23/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLSiezureLabel : UILabel

@property (nonatomic, assign) BOOL shouldColor;

- (void)start;
- (void)stop;

@end
