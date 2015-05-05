//
//  BLStartViewController.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/20/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLStartViewController.h"
#import "ViewController.h"
#import "SVProgressHUD.h"
#import "Apsalar.h"

@interface BLStartViewController () {
    AVAssetExportSession *exporter;
}

@end

@implementation BLStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)start:(id)sender
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [as showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    AVAsset *asset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
    
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showWithStatus:@"Cropping..."];
    [self cropVideoSquare:asset completion:^(NSURL *assetURL) {
        
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"main"];
        vc.assetToLoad = asset;
        [self.navigationController pushViewController:vc animated:YES];
        [SVProgressHUD dismiss];
    }];
}

- (void)cropVideoSquare:(AVAsset *)asset completion:(void (^)(NSURL *assetURL))completionHandler
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //create an avassetrack with our asset
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        //create a video composition and preset some settings
        AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.frameDuration = CMTimeMake(1, 30);
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
                
        //create a video instruction
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
        
        AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
        
        CGAffineTransform t1;
        CGAffineTransform final;
        
        if ([self orientationForTrack:asset] == UIInterfaceOrientationLandscapeLeft) {
            final = CGAffineTransformMakeTranslation(- (clipVideoTrack.naturalSize.width / 2 - videoComposition.renderSize.height / 2), 0);
        }
        else if ([self orientationForTrack:asset] == UIInterfaceOrientationLandscapeRight) {
            t1 = CGAffineTransformMakeTranslation(videoComposition.renderSize.width + (clipVideoTrack.naturalSize.width / 2 - videoComposition.renderSize.height / 2), clipVideoTrack.naturalSize.height);
            final = CGAffineTransformRotate(t1, M_PI);
            
        }
        else if ([self orientationForTrack:asset] == UIInterfaceOrientationPortraitUpsideDown) {
            t1 = CGAffineTransformMakeTranslation(0, clipVideoTrack.naturalSize.height + clipVideoTrack.naturalSize.height / 2);
            final = CGAffineTransformRotate(t1, M_PI + M_PI_2);
            
        }
        else if ([self orientationForTrack:asset] == UIInterfaceOrientationPortrait) {
            t1 = CGAffineTransformMakeTranslation(videoComposition.renderSize.height, - ((clipVideoTrack.naturalSize.width - videoComposition.renderSize.height) / 2));
            final = CGAffineTransformRotate(t1, M_PI_2);
        }
        
        CGAffineTransform finalTransform = final;
        [transformer setTransform:finalTransform atTime:kCMTimeZero];
        
        //add the transformer layer instructions, then add to video composition
        instruction.layerInstructions = [NSArray arrayWithObject:transformer];
        videoComposition.instructions = [NSArray arrayWithObject: instruction];
        
        //Create an Export Path to store the cropped video
        NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *exportPath = [documentsPath stringByAppendingFormat:@"/CroppedVideo.mp4"];
        NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
        
        //Remove any prevouis videos at that path
        [[NSFileManager defaultManager]  removeItemAtURL:exportUrl error:nil];
        
        //Export
        exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
        exporter.videoComposition = videoComposition;
        exporter.outputURL = exportUrl;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (completionHandler) {
                     completionHandler(exporter.outputURL);
                 }
             });
         }];
    });
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.mediaTypes = @[(NSString *)kUTTypeMovie];
    controller.delegate = self;
    
    if (buttonIndex == 0) {
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [Apsalar event:@"picker-camera"];
    }
    else if (buttonIndex == 1) {
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [Apsalar event:@"picker-library"];
    }
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
