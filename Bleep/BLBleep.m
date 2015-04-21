//
//  BLBleep.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/17/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLBleep.h"

@implementation BLBleep

- (void)setEnd:(CMTime)end
{
    _end = end;
    _duration = CMTimeSubtract(_end, _beginning);
}

- (NSURL *)fileURL
{
    return [[NSBundle mainBundle] URLForResource:_fileName withExtension:@"wav"];
}

@end
