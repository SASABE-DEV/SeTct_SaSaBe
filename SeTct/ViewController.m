//
//  ViewController.m
//  SeTct
//
//  Created by kunii on 2014/10/09.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "ViewController.h"
#import "TTRRecordManager.h"
#import "TTRLoginViewController.h"
#import "TTRAgreeViewController.h"
#import "TTRWebViewController.h"

@interface ViewController ()<
TTRLoginViewControllerDelegate,
TTRRecordManagerDelegate,
TTRAgreeViewControllerDelegate,
TTRWebViewControllerDelegate> {
    TTRRecordManager*   _manager;       /// 通信マネージャ
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView; /// 通信中に回す。
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_manager == nil) {
        //  通信マネージャ作成と初期化
        _manager = [[TTRRecordManager alloc] init];
        _manager.delegate = self;
        //  ログイン画面表示
        [self performSegueWithIdentifier:@"showLoginView" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - セグエ

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLoginView"]) {
        //  ログイン画面では、ユーザー名とパスワードを入力する。
        TTRLoginViewController* c = (TTRLoginViewController*)segue.destinationViewController;
        c.delegate = self;

        //  デバッグ用
//        c.name = @"kashina2";
//        c.password = @"kashina2";
        return;
    }
    if ([segue.identifier isEqualToString:@"showAgreeView"]) {
        //  承認画面は、使用許諾書を承認してもらう。
        TTRAgreeViewController* c = (TTRAgreeViewController*)segue.destinationViewController;
        c.delegate = self;
        return;
    }
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        //  ウエブ画面では、通信マネージャ指定のURLを表示するのみ。
        TTRWebViewController* c = (TTRWebViewController*)segue.destinationViewController;
        c.delegate = self;
        c.URLRequest = _manager.homeURLRequest;
    }
}

#pragma mark - TTRLoginViewControllerデリゲート

//  ログイン画面の設定をもらい、ログイン開始。
- (void)didDismissLoginViewController:(TTRLoginViewController*)controller {
    _manager.name = controller.name;
    _manager.password = controller.password;
    //  ログイン開始。
    [_activityIndicatorView startAnimating];
    [_manager login];
}

#pragma mark - TTRAgreeViewControllerデリゲート

//  使用許諾書承認もしくはキャンセル
- (void)agreeViewController:(TTRAgreeViewController*)contoller didDismissWithAgree:(BOOL)agree {
    if (agree) {
        //  承諾したのでデバイス登録開始。
        [_activityIndicatorView startAnimating];
        [_manager updateDevice];
    } else {
        //  未承諾なのでログイン画面に戻る。
        [self performSegueWithIdentifier:@"showLoginView" sender:self];
    }
}

#pragma mark - TTRWebViewControllerデリゲート

//  ウエブ画面からのアクションリクエスト
- (void)webViewController:(TTRWebViewController *)controller withAction:(NSString *)action {
    if ([action isEqualToString:@"Logout"]) {
        //  ログアウトリクエスト
        [self dismissViewControllerAnimated:YES completion:^{
            [_activityIndicatorView startAnimating];
            [_manager stopSession];    //  セッション停止
            [_manager logout];
        }];
    } else {

    }
}

#pragma mark - TTRRecordManagerデリゲート

//  エラー
- (void)recordManager:(TTRRecordManager*)recordManager didFailWithError:(NSError*)error {
    [_activityIndicatorView stopAnimating];
    NSLog(@"didFailWithError = %@", error.localizedDescription);
    //  エラーを通知。ログイン画面に戻る。
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"通信エラー" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"了解", nil];
    [alert show];
}

//  ログイン結果
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveLoginResponse:(NSDictionary*)responce {
    [_activityIndicatorView stopAnimating];
    if ([responce[@"status"] isEqualToString:@"NG"]) {
        //  ユーザー名かパスワード間違いの可能性。ログイン画面に戻る。
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ログインできません" message:@"ユーザIDかパスワードが間違っています。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"了解", nil];
        [alert show];
        return;
    }
    if ([responce[@"device"] isEqualToString:_manager.identifier]) {
        //  デバイスIDが一致するのでログイン成功。ウエブ画面表示。
        [_manager startSession];    //  セッション開始
        [self performSegueWithIdentifier:@"showWebView" sender:self];
        return;
    }
    //  使用許諾書画面表示
    [self performSegueWithIdentifier:@"showAgreeView" sender:self];
}

//  ログアウト
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveLogoutResponse:(NSDictionary*)responce {
    [_activityIndicatorView stopAnimating];
    //  現在サーバーが有効な値を返さない。何もチェックせずログイン画面を表示する。
    [self performSegueWithIdentifier:@"showLoginView" sender:self];    
}

//  デバイス更新結果
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveUpdateDeviceResponse:(NSDictionary*)responce {    
    [_activityIndicatorView stopAnimating];
    if ([responce[@"status"] isEqualToString:@"NG"]) {
        //  NGは承認まで待ってもらう事を通知。ログイン画面に戻る。
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"登録完了" message:@"登録の承認を管理者へ依頼しました。\n承認後に接続することができます。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"了解", nil];
        [alert show];
        return;
    }
    if ([responce[@"device"] isEqualToString:_manager.identifier]) {
        //  デバイスIDが一致するのでログイン成功。ウエブ画面表示。
        [self performSegueWithIdentifier:@"showWebView" sender:self];
        return;
    }
    //  ミスなのでログアウトする。
    [_activityIndicatorView startAnimating];
    [_manager logout];
}

//  セッションチェック結果
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveSessionResponse:(NSDictionary*)responce {
    if ([responce[@"status"] isEqualToString:@"NG"]) {
        //  NGなのでその旨を通知。ログイン画面に戻る。
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"セッション切れ" message:@"もう一度ログインからやり直してみてください。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"了解", nil];
            [alert show];
        }];
    }
}

//  アラート画面が閉じられたらログイン画面表示。
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"showLoginView" sender:self];
}

@end
