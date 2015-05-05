//
//  BLRedButton.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/28/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLRedButton.h"

@implementation BLRedButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIFont *font = [UIFont fontWithName:@"Moon-Bold" size:16];
    [self.titleLabel setFont:font];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height / 2];
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.925 green:0.137 blue:0.165 alpha:1.000].CGColor);
    [bezierPath fill];
}


@end
