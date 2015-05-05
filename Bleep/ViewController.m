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

@interface ViewController () {
    BOOL _watermark;
}

@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) BLBleep *currentBleep;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _watermark = YES;
    
    if (!self.playbackMode) {
        if (!self.times) {
            self.times = [NSMutableArray new];
        }
        [self setupCensorPlayer];
    }
    else {
        self.title = @"Save it";
        self.bleepButton.hidden = YES;
    }
    
    [self loadAppropriateAsset];
    [self syncUI];
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topLabel.shouldColor = YES;
    
    [self reset];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // align the save button if we've removed the watermark button
    [self syncBottomConstraints];
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

- (void)setupNotifications
{
    __weak id weakSelf = self;
    // Listen for IAP notification
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      __strong id strongSelf = weakSelf;
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [SVProgressHUD showSuccessWithStatus:@"Removed!"];
                                                      });
                                                      [strongSelf watermarkRemoved];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [SVProgressHUD dismiss];
                                                      });
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseDeferredNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [SVProgressHUD dismiss];
                                                      });
                                                  }];
}

- (void)dealloc
{
    [self.videoPlayerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKStoreKitProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKStoreKitProductPurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKStoreKitProductPurchaseDeferredNotification object:nil];
}

#pragma mark - Methods

- (void)syncUI
{
    if ((self.videoPlayer.currentItem != nil) && ([self.videoPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        if (!self.playbackMode) {
            self.bleepButton.enabled = YES;
            self.playButton.hidden = NO;
        }
        else {
            self.bleepButton.enabled = NO;
            self.playButton.hidden = YES;
        }
    }
    else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.bleepButton.enabled = NO;
        self.playButton.hidden = YES;
    }
    
    self.bottomView.hidden = !self.playbackMode;
    self.descriptionLabel.hidden = self.playbackMode;
}

- (void)syncBottomConstraints
{
    if ([[MKStoreKit sharedKit] isProductPurchased:@"com.sick.af.removewatermark"]) {
        self.watermarkButton.hidden = YES;
        [self.bottomView removeConstraint:self.bottomSpaceConstraint];
        NSLayoutConstraint *newC = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.saveButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.bottomView addConstraint:newC];
        [self.bottomView layoutIfNeeded];
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
    if (self.videoPlayerItem) {
        [self.videoPlayerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
    }
    
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

- (void)constructCensoredVideo
{
    if (self.videoPlayer.muted) {
        [self stopBleep:nil];
    }
    
    if (self.times.count <= 0) {
        [self showNoBleepAlert];
        [self reset];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    BLMovieRenderer *movieRenderer = [BLMovieRenderer new];
    if ([[MKStoreKit sharedKit] isProductPurchased:@"com.sick.af.removewatermark"]) {
        movieRenderer.hasWatermark = NO;
    }
    
    __weak id weakSelf = self;
    [movieRenderer renderVideoAsset:self.originalAsset ?: self.videoPlayerItem.asset bleepInfo:[self.times mutableCopy] completion:^(NSURL *assetURL) {
        __strong ViewController *strongSelf = weakSelf;
        if (strongSelf.playbackMode) {
            [strongSelf loadAssetFromURL:assetURL];
            [SVProgressHUD dismiss];
        }
        else {
            [SVProgressHUD dismiss];
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            ViewController *new = [mainSB instantiateViewControllerWithIdentifier:@"main"];
            new.assetURLToLoad = assetURL;
            new.originalAsset = self.videoPlayerItem.asset;
            new.playbackMode = YES;
            new.times = [strongSelf.times copy];
            [strongSelf.navigationController pushViewController:new animated:YES];
            [strongSelf.times removeAllObjects];
        }
    }];
}

- (void)showNoBleepAlert
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"No Bleeps" message:@"You forgot to bleep your vid. Touch your finger down on the video when you want a bleep to play." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [al show];
}

- (void)reset
{
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self syncUI];
}

#pragma mark - Actions

- (IBAction)play:(id)sender
{
    [self.videoPlayer play];
    
    self.playButton.hidden = YES;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bleep:(id)sender
{
    BLBleep *bleep = [BLBleep new];
    bleep.beginning = self.videoPlayer.currentTime;
    self.currentBleep = bleep;
    
    self.videoPlayer.muted = YES;
    [self.soundPlayer play];
    
    [(BLSiezureView *)self.view startAnimating];
    [self.topLabel start];
    [self.descriptionLabel start];
}

- (IBAction)stopBleep:(id)sender
{
    _currentBleep.end = self.videoPlayer.currentTime;
    [self.times addObject:_currentBleep];
    
    self.videoPlayer.muted = NO;
    [self.soundPlayer pause];
    
    [(BLSiezureView *)self.view stopAnimating];
    [self.topLabel stop];
    [self.descriptionLabel stop];
}

- (IBAction)save:(id)sender
{
    [SVProgressHUD showWithStatus:@"Saving..."];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:self.assetURLToLoad]) {
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.assetURLToLoad completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Saved!"];
            });
        }];
    }
}

- (IBAction)removeWatermark:(id)sender
{
    [SVProgressHUD showWithStatus:@"Removing..."];
    
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"com.sick.af.removewatermark"];
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
        [self play:nil];
    }
}

- (void)watermarkRemoved
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self constructCensoredVideo];
        [self syncBottomConstraints];
    });
}

@end
