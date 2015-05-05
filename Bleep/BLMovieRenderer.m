//
//  BLMovieRenderer.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/21/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLMovieRenderer.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define kVideoWidth 640

NSString *const tracksKey = @"tracks";

@interface BLMovieRenderer ()

@property (nonatomic) AVURLAsset *censorSound;
@property (nonatomic) AVAsset *videoAsset;

@property (nonatomic) AVMutableAudioMix *audioMix;
@property (nonatomic) AVMutableVideoComposition *videoComposition;

@end

@implementation BLMovieRenderer

- (id)init
{
    self = [super init];
    if (self) {
        self.hasWatermark = YES;
    }
    return self;
}

- (void)renderVideoAsset:(AVAsset *)videoAsset bleepInfo:(NSArray *)bleeps completion:(void (^)(NSURL *assetURL))completionHandler
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // Initialize bleep
        if (bleeps.count > 0) {
            AVURLAsset *soundAsset = [AVURLAsset URLAssetWithURL:[bleeps[0] fileURL] options:nil];
            self.censorSound = soundAsset;
        }
        
        self.videoAsset = videoAsset;
        
        [self.censorSound loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
            
            AVMutableComposition *mutableComposition = [AVMutableComposition composition];
            
            AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            
            AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            AVMutableCompositionTrack *secondAudioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            AVAssetTrack *firstVideoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            
            AVAssetTrack *videoAudioTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            
            // add video
            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration) ofTrack:firstVideoAssetTrack atTime:kCMTimeZero error:nil];
            
            // add original audio
            [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAudioTrack.timeRange.duration) ofTrack:videoAudioTrack atTime:kCMTimeZero error:nil];
            
            self.audioMix = [AVMutableAudioMix audioMix];
            
            // Create the audio mix input parameters object.
            AVMutableAudioMixInputParameters *volumeParam = [AVMutableAudioMixInputParameters audioMixInputParameters];
            volumeParam.trackID = audioCompositionTrack.trackID;
            
            // add bleeps
            for (int x = 0; x < bleeps.count; x++) {
                BLBleep *bleep = bleeps[x];
                CMTimeRange range = CMTimeRangeMake(bleep.beginning, bleep.duration);
                [secondAudioCompositionTrack insertTimeRange:range ofTrack:[[self.censorSound tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:bleep.beginning error:nil];
                
                [volumeParam setVolumeRampFromStartVolume:1.0f toEndVolume:0.0f timeRange:CMTimeRangeMake(bleep.beginning, CMTimeMake(1, 100))];
                [volumeParam setVolumeRampFromStartVolume:0.0f toEndVolume:1.0f timeRange:CMTimeRangeMake(bleep.end, CMTimeMake(1, 100))];
            }
            
            self.audioMix.inputParameters = @[volumeParam];
            
            AVMutableVideoCompositionInstruction *mutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            mutableVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);
            mutableVideoCompositionInstruction.backgroundColor = [[UIColor redColor] CGColor];
            
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];

            mutableVideoCompositionInstruction.layerInstructions = @[passThroughLayer];
            
            self.videoComposition = [AVMutableVideoComposition videoComposition];
            self.videoComposition.renderSize = CGSizeMake(firstVideoAssetTrack.naturalSize.width, firstVideoAssetTrack.naturalSize.height);
            self.videoComposition.frameDuration = CMTimeMake(1, 30);
            self.videoComposition.instructions = @[mutableVideoCompositionInstruction];
            
            // watermark
            UIImage *myImage = [UIImage imageNamed:@"logo"];
            CALayer *aLayer = [CALayer layer];
            aLayer.contents = (id)myImage.CGImage;
            aLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width / 4, self.videoComposition.renderSize.width / 4 * 0.17);
            aLayer.opacity = 1.0;
            
            CALayer *watermarkLayer = aLayer;
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
            videoLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
            [parentLayer addSublayer:videoLayer];
            watermarkLayer.position = CGPointMake(self.videoComposition.renderSize.width/6, self.videoComposition.renderSize.height/16);
            [parentLayer addSublayer:watermarkLayer];
            self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            // Create immutable copy of our composition
            AVComposition *immutableSnapshotOfMyComposition = [mutableComposition copy];
            
            // Export the composition to a file
            AVAssetExportSession *export = [AVAssetExportSession exportSessionWithAsset:immutableSnapshotOfMyComposition presetName:AVAssetExportPresetHighestQuality];
            
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"rendered"] stringByAppendingPathExtension:@"mp4"];
            
            // Delete old file
            NSError *error;
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:filePath]) {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                if (!success) {
                    NSLog(@"Error removing file at path: %@", error.localizedDescription);
                }
            }
            
            NSURL *outputURL = [NSURL fileURLWithPath:filePath];
            
            [export setOutputURL:outputURL];
            
            [export setOutputFileType:AVFileTypeMPEG4];
            export.shouldOptimizeForNetworkUse = YES;
            [export setAudioMix:self.audioMix];
            
            // add video composition if need be
            if (self.hasWatermark) {
                [export setVideoComposition:self.videoComposition];
            }
            
            [export exportAsynchronouslyWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (completionHandler) {
                        completionHandler(outputURL);
                    }
                });
            }];
        }];
    });
}

@end
