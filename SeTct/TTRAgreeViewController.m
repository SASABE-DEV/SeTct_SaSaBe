//
//  TTRAgreeViewController.m
//  SeTct
//
//  Created by kunii on 2014/10/10.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "TTRAgreeViewController.h"

@interface TTRAgreeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TTRAgreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _registrationButton.enabled = NO;
    
    NSURL* url = [NSBundle.mainBundle URLForResource:@"uses" withExtension:@"txt"];
    _textView.text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    _textView.layer.borderWidth = 0.5;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _textView.contentOffset = CGPointZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)agree:(UISwitch *)sender {
    _registrationButton.enabled = sender.on;
}

- (IBAction)registration {
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate agreeViewController:self didDismissWithAgree:YES];
    }];
}

- (IBAction)cancel {
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate agreeViewController:self didDismissWithAgree:NO];
    }];
}
@end
