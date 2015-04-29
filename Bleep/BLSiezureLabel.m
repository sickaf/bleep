//
//  BLSiezureLabel.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/23/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLSiezureLabel.h"

@implementation BLSiezureLabel

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self stopWhite:text];
}

- (void)setShouldColor:(BOOL)shouldColor
{
    _shouldColor = shouldColor;
    if (shouldColor) {
        [self stopWhite:self.attributedText.string];
    }
}

- (void)start
{
    [self startWhite:self.attributedText.string];
}

- (void)stop
{
    [self stopWhite:self.attributedText.string];
}

- (void)startWhite:(NSString *)text
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.text];
    UIFont *font = [self customFont];
    [title addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
    
    //add color
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, title.length)];
    
    self.attributedText = title;
}

- (void)stopWhite:(NSString *)text
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.text];
    UIFont *font = [self customFont];
    [title addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
    
    if (self.shouldColor) {
        //add color
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.910 green:0.122 blue:0.173 alpha:1.000] range:NSMakeRange(0, 1)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.992 green:0.835 blue:0.251 alpha:1.000] range:NSMakeRange(2, 1)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.192 green:0.937 blue:0.729 alpha:1.000] range:NSMakeRange(4, 1)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.165 green:0.765 blue:0.176 alpha:1.000] range:NSMakeRange(6, 1)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.875 green:0.000 blue:0.925 alpha:1.000] range:NSMakeRange(8, 1)];
    }
    
    self.attributedText = title;
}

- (UIFont *)customFont
{
    UIFont *font = [UIFont fontWithName:@"Moon-Bold" size:self.font.pointSize];
    return font;
}

@end
