//
//  ViewController.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/16/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "ViewController.h"
#import "BLBleep.h"
#import "SVProgressHUD.h"
#import "BLMovieRenderer.h"

static const NSString *ItemStatusContext;

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) BLBleep *currentBleep;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    if (!self.playbackMode) {
        self.title = @"Bleep it";
        self.times = [NSMutableArray new];
        [self setupCensorPlayer];
        self.saveButton.hidden = YES;
    }
    else {
        self.title = @"Save it";
        self.bleepButton.hidden = YES;
        self.descriptionLabel.hidden = YES;
    }
    
    [self loadAppropriateAsset];
    [self syncUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.videoPlayer seekToTime:kCMTimeZero];
}

- (void)setupUI
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
}

- (void)setupCensorPlayer
{
    NSError *err;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"censor" withExtension:@"wav"];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    audioPlayer.numberOfLoops = -1;
    self.soundPlayer = audioPlayer;
}

- (void)loadAppropriateAsset
{
    if (self.assetURLToLoad) {
        [self loadAssetFromURL:self.assetURLToLoad];
    }
    else if (self.assetToLoad) {
        [self loadAsset:self.assetToLoad];
    }
}

- (void)dealloc
{
    [self.videoPlayerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
}

#pragma mark - Methods

- (void)syncUI
{
    if ((self.videoPlayer.currentItem != nil) && ([self.videoPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.bleepButton.enabled = YES;
    }
    else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.bleepButton.enabled = NO;
    }
}

- (void)loadAssetFromURL:(NSURL *)assetURL
{
    // remove any observers
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    [self loadAsset:asset];
}

- (void)loadAsset:(AVAsset *)asset
{
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            NSError *error;
                            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            
                            if (status == AVKeyValueStatusLoaded) {
                                self.videoPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
                                // ensure that this is done before the playerItem is associated with the player
                                [self.videoPlayerItem addObserver:self forKeyPath:@"status"
                                                          options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                                [[NSNotificationCenter defaultCenter] addObserver:self
                                                                         selector:@selector(playerItemDidReachEnd:)
                                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                                           object:self.videoPlayerItem];
                                self.videoPlayer = [AVPlayer playerWithPlayerItem:self.videoPlayerItem];
                                [self.videoPlayerView setPlayer:self.videoPlayer];
                                if (self.playbackMode) {
                                    [self play:nil];
                                }
                            }
                            else {
                                // You should deal with the error appropriately.
                                NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                            }
                        });
         
     }];
}

#pragma mark - Actions

- (void)play:sender
{
    [self.videoPlayer play];
}

- (IBAction)bleep:(id)sender
{
    BLBleep *bleep = [BLBleep new];
    bleep.beginning = self.videoPlayer.currentTime;
    self.currentBleep = bleep;
    
    self.videoPlayer.muted = YES;
    [self.soundPlayer play];
}

- (IBAction)stopBleep:(id)sender
{
    _currentBleep.end = self.videoPlayer.currentTime;
    [self.times addObject:_currentBleep];
    
    self.videoPlayer.muted = NO;
    [self.soundPlayer pause];
}

- (IBAction)save:(id)sender
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:self.assetURLToLoad]) {
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.assetURLToLoad completionBlock:NULL];
    }
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (!self.playbackMode) {
        [self constructCensoredVideo];
    }
    else {
        [self.videoPlayer seekToTime:kCMTimeZero];
    }
}

- (void)constructCensoredVideo
{
    if (self.videoPlayer.muted) {
        [self stopBleep:nil];
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    BLMovieRenderer *movieRenderer = [BLMovieRenderer new];
    [movieRenderer renderVideoAsset:self.videoPlayerItem.asset bleepInfo:[self.times mutableCopy] completion:^(NSURL *assetURL) {
        [SVProgressHUD dismiss];
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ViewController *new = [mainSB instantiateViewControllerWithIdentifier:@"main"];
        new.assetURLToLoad = assetURL;
        new.playbackMode = YES;
        [self.navigationController pushViewController:new animated:YES];
        
        [self.times removeAllObjects];
    }];
}

@end
