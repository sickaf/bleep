//
//  ViewController.h
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/16/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "BLPlayerView.h"

@interface ViewController : UIViewController

@property (nonatomic) AVPlayer *videoPlayer;
@property (nonatomic) AVPlayerItem *videoPlayerItem;
@property (nonatomic, weak) IBOutlet BLPlayerView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *bleepButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic) AVAudioPlayer *soundPlayer;

@property (nonatomic) AVAsset *assetToLoad;
@property (nonatomic, strong) NSURL *assetURLToLoad;

@property (nonatomic, assign) BOOL playbackMode;

- (void)play:sender;
- (IBAction)bleep:(id)sender;
- (IBAction)stopBleep:(id)sender;
- (IBAction)save:(id)sender;

@end

