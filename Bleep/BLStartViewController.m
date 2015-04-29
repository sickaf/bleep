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

@interface BLStartViewController ()

@end

@implementation BLStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)start:(id)sender
{
    IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)info:(id)sender
{
    
}

#pragma mark - Image Picker Delegate

- (void)assetsPicker:(id)picker finishedCroppingWithAsset:(id)asset
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"main"];
    vc.assetToLoad = asset;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:YES];
    });
}

@end
