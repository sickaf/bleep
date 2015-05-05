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
#import "BLSiezureView.h"
#import "BLSiezureLabel.h"
#import "BLRedButton.h"
#import "MKStoreKit.h"

@interface ViewController : UIViewController

@property (nonatomic) AVPlayer *videoPlayer;
@property (nonatomic) AVPlayerItem *videoPlayerItem;
@property (nonatomic, weak) IBOutlet BLPlayerView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *bleepButton;
@property (weak, nonatomic) IBOutlet BLSiezureLabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet BLSiezureLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet BLRedButton *saveButton;
@property (weak, nonatomic) IBOutlet BLRedButton *watermarkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

@property (nonatomic) AVAudioPlayer *soundPlayer;

@property (nonatomic) AVAsset *assetToLoad;
@property (nonatomic) AVAsset *originalAsset;
@property (nonatomic, strong) NSURL *assetURLToLoad;

@property (nonatomic, assign) BOOL playbackMode;

- (void)play:sender;
- (IBAction)bleep:(id)sender;
- (IBAction)stopBleep:(id)sender;
- (IBAction)save:(id)sender;

@end

