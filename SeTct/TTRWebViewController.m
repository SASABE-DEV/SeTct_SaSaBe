//
//  TTRWebViewController.m
//  SeTct
//
//  Created by kunii on 2014/10/10.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "TTRWebViewController.h"
#import "TTRRecordManager.h"

@interface TTRWebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;

@end

@implementation TTRWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView loadRequest:_URLRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout {
    [_delegate webViewController:self withAction:@"Logout"];
}

- (IBAction)home {
    [_webView loadRequest:_URLRequest];
    [_delegate webViewController:self withAction:@"Home"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) { // リンクがクリックされた。
        NSString* str = [request.URL standardizedURL].absoluteString;
        NSRange range = [str rangeOfString:@"webroot"];
        if (range.location != NSNotFound) {
            [[UIApplication sharedApplication] openURL:[request.URL standardizedURL]];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_activityIndicatorView startAnimating];
    _failLabel.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_activityIndicatorView stopAnimating];
    _failLabel.hidden = NO;
    
}
@end
