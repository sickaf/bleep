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
#import "IGAssetsPicker.h"
#import "BLSiezureView.h"
#import "BLSiezureLabel.h"
#import "BLRedButton.h"

@interface ViewController : UIViewController <IGAssetsPickerDelegate>

@property (nonatomic) AVPlayer *videoPlayer;
@property (nonatomic) AVPlayerItem *videoPlayerItem;
@property (nonatomic, weak) IBOutlet BLPlayerView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *bleepButton;
@property (weak, nonatomic) IBOutlet BLSiezureLabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet BLSiezureLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet BLRedButton *saveButton;

@property (nonatomic) AVAudioPlayer *soundPlayer;

@property (nonatomic) AVAsset *assetToLoad;
@property (nonatomic, strong) NSURL *assetURLToLoad;

@property (nonatomic, assign) BOOL playbackMode;

- (void)play:sender;
- (IBAction)bleep:(id)sender;
- (IBAction)stopBleep:(id)sender;
- (IBAction)save:(id)sender;

@end

