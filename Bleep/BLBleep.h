//
//  BLBleep.h
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/17/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BLBleep : NSObject

@property (nonatomic, assign) CMTime beginning;
@property (nonatomic, assign) CMTime end;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *fileURL;

@end
