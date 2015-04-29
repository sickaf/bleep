//
//  BLInfoViewController.m
//  Bleep
//
//  Created by Cody Kolodziejzyk on 4/29/15.
//  Copyright (c) 2015 sick.af. All rights reserved.
//

#import "BLInfoViewController.h"

@interface BLInfoViewController () <UIWebViewDelegate> {
    UIActivityIndicatorView *_spinner;
}

@end

@implementation BLInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"sick.af";
    NSString *fullURL = @"http://sick.af";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:requestObj];
    
    UIActivityIndicatorView *spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spin.hidesWhenStopped = YES;
    _spinner = spin;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spin];
}

#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_spinner stopAnimating];
}

#pragma mark - Actions
- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
