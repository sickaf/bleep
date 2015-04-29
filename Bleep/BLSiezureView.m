//
//  BLSiezureView.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/23/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLSiezureView.h"

@interface BLSiezureView ()

@property (nonatomic, strong) NSArray *colors;

@end

@implementation BLSiezureView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.colors = @[(id)[UIColor colorWithRed:0.910 green:0.122 blue:0.173 alpha:1.000].CGColor,
                        (id)[UIColor colorWithRed:0.992 green:0.835 blue:0.251 alpha:1.000].CGColor,
                        (id)[UIColor colorWithRed:0.192 green:0.937 blue:0.729 alpha:1.000].CGColor,
                        (id)[UIColor colorWithRed:0.165 green:0.765 blue:0.176 alpha:1.000].CGColor,
                        (id)[UIColor colorWithRed:0.875 green:0.000 blue:0.925 alpha:1.000].CGColor];
    }
    return self;
}

- (void)startAnimating
{
    //Create animation
    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    colorsAnimation.values = self.colors;
    colorsAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.2], [NSNumber numberWithFloat:0.3],[NSNumber numberWithFloat:0.4],[NSNumber numberWithFloat:0.5], nil];
    colorsAnimation.calculationMode = kCAAnimationPaced;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.repeatCount = CGFLOAT_MAX;
    colorsAnimation.fillMode = kCAFillModeForwards;
    colorsAnimation.duration = 0.5f;
    
    //Add animation
    [self.layer addAnimation:colorsAnimation forKey:nil];
}

- (void)stopAnimating
{
    [self.layer removeAllAnimations];
}

@end
