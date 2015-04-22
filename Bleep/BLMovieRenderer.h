//
//  BLMovieRenderer.h
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/21/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "BLBleep.h"

@interface BLMovieRenderer : NSObject

- (void)renderVideoAsset:(AVAsset *)videoAsset bleepInfo:(NSArray *)bleeps completion:(void (^)(NSURL *assetURL))completionHandler;

@end
