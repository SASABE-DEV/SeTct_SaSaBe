//
//  TTRWebViewController.m
//  SeTct
//
//  Created by kunii on 2014/10/10.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "TTRWebViewController.h"
#import "TTRRecordManager.h"

@interface TTRWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

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
@end
