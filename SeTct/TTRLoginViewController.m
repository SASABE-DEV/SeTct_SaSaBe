//
//  TTRLoginViewController.m
//  SeTct
//
//  Created by kunii on 2014/10/09.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "TTRLoginViewController.h"
#import "TTRRecordManager.h"

@interface TTRLoginViewController ()<UITextFieldDelegate> {
    UITextField* _textField;
    BOOL _passwordFirstKey;
}
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TTRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _loginButton.enabled = (_name.length > 0) && (_password.length > 0);
    _userIDTextField.text = _name;
    _passwordTextField.text = _password;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - バックグラウンド移行対応

- (void)didEnterBackgroundNotification {
    //    _passwordTextField.text = nil;
    //    _loginButton.enabled = NO;
}

/// ログイン開始
- (IBAction)login {
    _name = _userIDTextField.text;
    _password = _passwordTextField.text;
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate didDismissLoginViewController:self];
    }];
}

#pragma mark - UITextFieldデリゲート

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textField = textField;
    if (textField == _passwordTextField) {
        _passwordFirstKey = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _textField = nil;
    _passwordFirstKey = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = 0;
    if (textField == _userIDTextField)
        length = _passwordTextField.text.length;
    else
        length = _userIDTextField.text.length;
    if (length == 0) {
        _loginButton.enabled = NO;
        return YES;
    }
    length = textField.text.length;
    NSUInteger newlength = [textField.text stringByReplacingCharactersInRange:range withString:string].length;
    _loginButton.enabled = newlength > 0;
    if ((textField == _passwordTextField) && _passwordFirstKey && _loginButton.enabled) {
        _loginButton.enabled = (newlength >= length);
    }
    _passwordFirstKey = NO;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    _loginButton.enabled = NO;
    return YES;
}

#pragma mark - タッチ

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [_textField resignFirstResponder];
}
@end
